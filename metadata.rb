name             'marketplace_ami'
maintainer       'Chef Partner Engineering'
maintainer_email 'partnereng@chef.io'
license          'Apache 2.0'
description      'Provides a marketplace_ami resource'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'build-essential'
depends 'xml'
