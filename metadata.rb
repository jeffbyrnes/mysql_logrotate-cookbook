name             'mysql_logrotate'
maintainer       'Roll No Rocks LLC'
maintainer_email 'tom@rollnorocks.com'
description      'Installs/Configures mysql_logrotate'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'logrotate', '~> 1.7'
depends 'mysql', '>= 6.0'
depends 'database'
