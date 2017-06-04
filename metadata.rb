name             'mysql_logrotate'
maintainer       'Roll No Rocks LLC'
maintainer_email 'tom@rollnorocks.com'
description      'Installs/Configures log rotation for mysql_service (mysql cookbook > 6.0)'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.2'

depends 'logrotate', '~> 2.1'
depends 'mysql', '>= 6.0'
depends 'database'
