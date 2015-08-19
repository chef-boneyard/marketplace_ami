#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Provider
    class MarketplaceAmi < Chef::Provider::LWRPBase
      provides :marketplace_ami

      require 'chef/dsl/include_recipe'
      include Chef::DSL::IncludeRecipe

      require 'chef/mixin/deep_merge'
      include Chef::Mixin::DeepMerge

      use_inline_resources

      attr_accessor :ami

      def whyrun_supported?
        true
      end

      action :create do
        create_image
        share_image
      end

      def create_image
        include_aws_driver

        with_driver 'aws::us-east-1'
        with_chef_server new_resource.chef_server_url if new_resource.chef_server_url
        with_machine_options deep_merge(resource_config, default_config)

        ami = machine_image(new_resource.name)

        new_resource.image_attributes.each { |path, value| ami.attribute(path, value) }
        new_resource.image_runlist.each { |method, value| ami.send(method, value) }

        ami.recipe(new_resource.security_recipe) if new_resource.security
        ami.recipe(new_resource.audit_recipe) if new_resource.audit
      end

      def share_image
        ruby_block "share #{new_resource.name} with the AWS Marketplace account" do
          block do
            aws_driver = run_context.chef_provisioning.current_driver
            current_options = run_context.chef_provisioning.current_machine_options
            chef_server = run_context.cheffish.current_chef_server
            aws = Chef::Provisioning::AWSDriver::Driver.from_url(aws_driver, current_options)

            aws_image = Chef::Resource::AwsImage.get_aws_object(
              new_resource.name,
              run_context: run_context,
              driver: aws_driver,
              managed_entry_store: Chef::Provisioning.chef_managed_entry_store(chef_server)
            )

            # Find the snapshot that was used to create the AMI
            # Each AMI should only have a single snapshot but because we have to parse
            # the shapshot description we might get more than one. Share them all just in
            # case.
            image_snapshots = aws.ec2.snapshots.with_owner('self').select do |snap|
              snap.description =~ /#{aws_image.id}/
            end

            # Share the snapshots and image with the aws-marketplace account
            aws_image.permissions.add('679593333241')
            image_snapshots.each { |snap| snap.permissions.add('679593333241') }

            # Add our image to the run_state
            node.run_state['marketplace_amis'] ||= []
            node.run_state['marketplace_amis'] << aws_image

            # Set the product code
            aws_image.add_product_codes(Array(new_resource.product_code)) if new_resource.product_code
          end
        end
      end

      def include_aws_driver
        require 'chef/provisioning/aws_driver'
      rescue LoadError
        # Nokogiri gotta compile (╯°□°）╯︵ ┻━┻
        node.set['build-essential']['compile_time'] = true
        node.set['xml']['compiletime'] = true

        include_recipe 'build-essential::default'
        include_recipe 'xml::default'

        chef_gem 'chef-provisioning-aws' do
          compile_time true
        end

        require 'chef/provisioning/aws_driver'
      end

      def default_config
        {
          bootstrap_options: {
            instance_type: 'm4.xlarge',
            availability_zone: 'us-east-1a',
            associate_public_ip_address: true
          },
          convergence_options: {
            chef_client_timeout: 7200,
            chef_version: '12.4.1'
          },
          ssh_username: 'ec2-user'
        }
      end

      def resource_config
        config = { bootstrap_options: {}, convergence_options: {} }
        config[:bootstrap_options][:instance_type] = new_resource.instance_type if new_resource.instance_type
        config[:bootstrap_options][:image_id] = new_resource.source_image_id if new_resource.source_image_id
        config[:bootstrap_options][:key_name] = new_resource.ssh_keyname if new_resource.ssh_keyname

        # FIXME: This branch can be removed and replaced with the commented line
        # when we properly strip 'key_path' from the bootstrap options.
        # https://github.com/chef/chef-provisioning-aws/pull/295
        if new_resource.ssh_keypath
          fail ArgumentError, 'You must provide a ssh_keyname when you supply a ssh_keypath' unless new_resource.ssh_keyname
          Chef::Config[:private_keys] ||= {}
          Chef::Config[:private_keys][new_resource.ssh_keyname] = new_resource.ssh_keypath
        end
        # config[:bootstrap_options][:key_path] = new_resource.ssh_keypath if new_resource.ssh_keypath

        config[:convergence_options][:chef_server_url] = new_resource.chef_server_url if new_resource.chef_server_url
        config[:convergence_options][:chef_config] = "audit_mode :enabled\n" if new_resource.audit
        deep_merge!(new_resource.machine_options, config) if new_resource.machine_options
        config
      end
    end
  end
end
