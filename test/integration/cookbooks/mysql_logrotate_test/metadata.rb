name             'mysql_logrotate_test'
maintainer       'Jeff Byrnes'
maintainer_email 'thejeffbyrnes@gmail.com'
license          'MIT'
description      'Tests a mysql_logrotate resource'
version          '0.1.0'
chef_version     '>= 12.11'

supports 'ubuntu', '= 16.04'

depends 'mysql_logrotate'
depends 'mysql'
