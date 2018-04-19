mysql_logrotate CHANGELOG
=========================

This file is used to list changes made in each version of the mysql_logrotate cookbook.

1.0.0
-----
- Refactor into Chef 12.5 Custom Resource
- Update Resource for Chef 14-compatibility
- Ensure that `mysql2_chef_gem` is used
- Update & automate test setup

0.2.2
-----
- Add default location for general & slow query logs when using mysql >= 8.0 cookbook.
  (/var/lib/mysql-#{name})

0.2.1
-----
- Updated resources file for new LWRP structure, replacing attributes with properties

0.2.0
-----
- Initial commit (previous commits destroyed, deemed dangerous and misleading.)
