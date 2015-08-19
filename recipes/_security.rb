#
# Cookbook Name:: marketplace_ami
# Recipe:: _security
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

MarketplaceAMIHelpers.user_directories.each do |usr, dir|
  %w(id_rsa id_rsa.pub authorized_keys).each do |ssh_file|
    file ::File.join(dir, '.ssh', ssh_file) do
      action :delete
    end
  end

  user usr do
    action :lock
  end

  file ::File.join(dir, '.bash_history') do
    action :delete
  end
end

MarketplaceAMIHelpers.system_ssh_keys.each do |key|
  file key do
    action :delete
  end
end

MarketplaceAMIHelpers.sudoers.each do |sudo_user|
  file sudo_user do
    action :delete
  end
end

%w(/etc/chef/client.rb /etc/chef/client.pem).each do |chef_file|
  file chef_file do
    action :delete
  end
end

directory '/var/log' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/tmp' do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

execute 'rm -rf /tmp/*' do
  not_if { Dir['/tmp/*'].empty? }
end

execute 'rm -rf /var/log/*' do
  not_if { Dir['/var/log/*'].empty? }
end
