#
# Cookbook Name:: marketplace_ami
# Recipe:: _security_controls
# Author:: Partner Engineering <partnereng@chef.io>
#
# Copyright (C) 2015 Chef Software, Inc.
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

cloud_init_enabled = MarketplaceAMIHelpers.cloud_init?(node)
default_user = MarketplaceAMIHelpers.default_user(node)
login_shell = MarketplaceAMIHelpers.login_shell(node)

control_group 'AMI Security' do
  let(:user_directories) { MarketplaceAMIHelpers.user_directories }
  let(:system_ssh_keys) { MarketplaceAMIHelpers.system_ssh_keys }
  let(:sudoers) { MarketplaceAMIHelpers.sudoers }

  control 'SSH' do
    it 'does not have any default keys' do
      user_directories.each do |_user, dir|
        expect(file("#{dir}/.ssh/id_dsa")).to_not be_file
        expect(file("#{dir}/.ssh/id_dsa.pub")).to_not be_file
        expect(file("#{dir}/.ssh/id_rsa")).to_not be_file
        expect(file("#{dir}/.ssh/id_rsa.pub")).to_not be_file
        expect(file("#{dir}/.ssh/authorized_keys")).to_not be_file
      end

      system_ssh_keys.each { |key| expect(file(key)).to_not be_file }
    end

    it 'is listening on port 22' do
      expect(port(22)).to be_listening
    end

    it 'does not allow root login' do
      expect(file('/etc/ssh/sshd_config')).to contain('PermitRootLogin no')
    end

    it 'disables DNS checks' do
      expect(file('/etc/ssh/sshd_config')).to contain('UseDNS no')
    end

    it 'has cloud-init enabled' do
      expect(package('cloud-init')).to be_installed
    end if cloud_init_enabled
  end

  control 'Authentication' do
    it 'users do not have a password' do
      user_directories.each do |user, _dir|
        expect(command("passwd -S #{user}").stdout).to match(/Password locked|Alternate authentication scheme in use/)
      end
    end

    it 'does not enable sudo access for other users' do
      expect(sudoers).to eq([])
    end

    it "#{default_user} is the default user" do
      expect(user(default_user)).to exist
      expect(user(default_user)).to have_home_directory("/home/#{default_user}")
      expect(user(default_user)).to have_login_shell(login_shell)
    end

    it 'does not have a password' do
      expect(command("passwd -S #{default_user}").stdout).to match(/Password locked/)
    end
  end

  control 'Chef' do
    it 'does not have chef config' do
      user_directories.each do |_user, dir|
        expect(file("#{dir}/.chef")).to_not be_directory
      end

      %w(/etc/chef/client.rb /etc/chef/client.pem).each do |chef_file|
        expect(file(chef_file)).to_not be_file
      end
    end
  end

  control 'History' do
    it 'does not have any old logs' do
      expect(Dir['/var/log/*']).to eq([])
    end

    it 'does not have user shell history' do
      user_directories.each do |_user, dir|
        expect(file("#{dir}/.bash_history")).to_not be_file
      end
    end
  end
end
