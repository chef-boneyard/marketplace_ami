log_level                :info
log_location             STDOUT
node_name                "zero"
chef_server_url          'http://127.0.0.1:8889'
private_key 'marketplace_builder' => ENV['MARKETPLACE_BUILDER_SSH_KEY_PATH']
