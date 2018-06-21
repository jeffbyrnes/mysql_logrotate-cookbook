mysql_logrotate CHANGELOG
=========================

This file is used to list changes made in each version of the mysql_logrotate cookbook.

2.0.0
-----
- Add `mysql_version` & `gem_version` properties:
    + As of a recent version of Chef 13, these are now necessary, thanks to how the `mysql_client` resource (hiding way under-the-covers of this cookbook) is evaluated
    + These are breaking b/c, while we set a default, it is quite likely to not be the MySQL version you have installed

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
