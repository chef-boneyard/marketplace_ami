# marketplace_ami Cookbook

The marketplace_ami cookbook provides a chef resource for publishing AMI's into the AWS Marketplace.  The resource will provision a new EC2 instance, converge your application cookbook, create an AMI and share it with AWS Marketplace.  Optionally you can enable a security recipe that will remove sensitive data and a chef-client audit mode recipe that will audit the image for known AWS security policies.

## Requirements

Chef 12.3.0 or higher.
Chef Provisioning 1.2.0 or higher.
Chef Provisioning AWS 1.2.1 or higher.

The latest versions are always recommended.

#### Cookbooks

* `build-essential`
* `xml`

Only to be used if chef-provisioning-aws has not been installed

## Attributes

The attributes in this cookbook are used only by the the security recipe and audit controls.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['marketplace_ami']['controls']['cloud_init_enabled']</tt></td>
    <td>Boolean</td>
    <td>Whether or not the security audit should expect cloud-init to installed</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_ami']['controls']['default_user']</tt></td>
    <td>String</td>
    <td>The default user for SSH access</td>
    <td><tt>ec2-user</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_ami']['controls']['login_shell']</tt></td>
    <td>String</td>
    <td>The default users login_shell</td>
    <td><tt>/bin/bash</tt></td>
  </tr>
</table>

## Resources

### marketplace_ami

Creates an AWS Marketplace AMI

#### Actions

* `create` - (default) Create an AWS Marketplace AMI

#### Properties
* `name` The name of the AMI.
* `product_code` The product code you wish to associate with the AMI
* `source_image_id` The base image to launch (Ubuntu 14.04)
* `instance_type` The size of the instance to launch (m4.xlarge)
* `ssh_keyname` The name of the SSH keypair (creates a default if not given)
* `ssh_keypath` The path to the private SSH key
* `ssh_username` The username (ubuntu)
* `chef_server_url` The URL to the Chef Server (local default)
* `machine_options` A Hash of additional chef-provisioning machine_options
* `security` Enable to disable the security recipe (false)
* `security_recipe` The security recipe (marketplace_ami::_security)
* `audit` Enable to disable the audit recipe (true)
* `audit_recipe` The audit recipe (marketplace_ami::_security_controls)
* `attribute` Set an attribute for the chef-client run
* `recipe` Add a recipe to the runlist
* `role` Add a role to the runlist

## Usage

Before you being you'll need to properly set up valid EC2 credentials on the node that will be converging the recipe.

Update the `metadata.rb` of your application's cookbook to depend on 'marketplace_ami'
```ruby
# your_application/metadata.rb

name 'your_application'
...
depends 'marketplace_ami'
```

Create a publishing recipe that utilizes the `marketplace_ami` resource to build your Marketplace AMI
```ruby
# your_application/recipes/ami_publisher.rb

marketplace_ami "your_application-#{node['your_application']['version']}" do
  instance_type   't2.medium'
  source_image_id 'ami-123456'
  ssh_keyname     'publisher'
  ssh_keypath     '~/.aws/publisher.pem'
  ssh_username    'ec2-user'
  product_code    '123799879'
  security        true
  audit           true

  role 'company_wide_role'
  recipe 'your_application::setup'
  recipe 'your_application::install'
  attribute %w(your_application tofu), 'yes'
  attribute %w(your_application brocolli), 'more_please'

  action :create
end
```

Run the chef-client!

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
