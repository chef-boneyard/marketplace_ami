# rubocop:disable Style/SingleSpaceBeforeFirstArg

marketplace_ami "test-#{Time.now.strftime('%F')}" do
  instance_type   node['test']['instance_type']
  source_image_id node['test']['source_image_id']
  ssh_keyname     node['test']['ssh_keyname']
  ssh_keypath     node['test']['ssh_keypath']
  ssh_username    node['test']['ssh_username']
  chef_server_url node['test']['chef_server_url']
  machine_options node['test']['machine_options']
  product_code    node['test']['product_code']
  security        node['test']['security']
  audit           node['test']['audit']

  recipe 'test::hello_world'
  attribute %w(test hello_world), 'Yay! our test image works'

  action :create
end
