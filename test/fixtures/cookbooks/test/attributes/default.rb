default['test']['instance_type'] = 't2.medium'
default['test']['source_image_id'] = 'ami-0372b468'
default['test']['ssh_keyname'] = 'marketplace_builder'
default['test']['ssh_username'] = 'ec2-user'
default['test']['ssh_keypath'] = ENV['MARKETPLACE_BUILDER_SSH_KEY_PATH']
default['test']['machine_options'] = {}
default['test']['product_code'] = nil
default['test']['security'] = false
default['test']['audit'] = true
default['test']['hello_world'] = 'Hello World!'