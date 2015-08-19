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
  class Resource
    class MarketplaceAmi < Chef::Resource::LWRPBase
      resource_name :marketplace_ami

      actions :create
      default_action :create

      # Image options
      attribute :name, name_attribute: true
      attribute :product_code, kind_of: String

      # Common machine options
      attribute :instance_type, kind_of: String
      attribute :source_image_id, kind_of: String
      attribute :ssh_keyname, kind_of: String
      attribute :ssh_keypath, kind_of: String
      attribute :ssh_username, kind_of: String
      attribute :chef_server_url, kind_of: String

      # Inject custom machine options
      attribute :machine_options, kind_of: Hash

      # Enable the security recipe
      attribute :security, kind_of: [TrueClass, FalseClass], default: false
      attribute :security_recipe, kind_of: String, default: 'marketplace_ami::_security'

      # Enable the audit recipe
      attribute :audit, kind_of: [TrueClass, FalseClass], default: true
      attribute :audit_recipe, kind_of: String, default: 'marketplace_ami::_security_controls'

      # Configure policy
      def attribute(attribute_path, value)
        @image_attributes ||= []
        image_attributes << [attribute_path, value]
      end

      def recipe(*recipes)
        @image_runlist ||= []
        if recipes.size == 0
          fail ArgumentError, 'At least one recipe must be specified'
        end
        @image_runlist += recipes.map { |recipe| [:recipe, recipe] }
      end

      def roles(*roles)
        @image_runlist ||= []
        if roles.size == 0
          fail ArgumentError, 'At least one role must be specified'
        end
        @image_runlist += roles.map { |role| [:role, role] }
      end

      def image_attributes
        @image_attributes || []
      end

      def image_runlist
        @image_runlist || []
      end
    end
  end
end
