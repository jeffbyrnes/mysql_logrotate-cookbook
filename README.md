# mysql_logrotate

Workaround for MySQL logrotate issues introduced with mysql cookbook v6.0.0

## The problem and workaround

The mysql cookbook < 6.0.0 does a default installation of mysql server, and includes a working `logrotate` config of its own.

Starting with V6.0.0, the cookbook was reconfigured to allow installing multiple mysql instances, and avoid managing the service provided by any package install.

This broke `logrotate` for MySQL in a few ways:

* The default `logrotate` setup is still created, but is set to rotate inactive logs, and the mysql user credentials (needed by the `logrotate` `postrotate` script to flush the logs) are not created.
    - See _"What about the default logrotate setup that keeps failing?"_ for one solution.
* `logrotate` is not set up for the new MySQL server instances' logs, with the same issue regarding credentials.

The intention of this cookbook is to implement working log rotation for any MySQL service created by `mysql` cookbook (>= 6.0.0) by copying the implementation created for the older cookbooks where this worked.

## Resources

### `mysql_logrotate_agent`

This resource is where everything happens:

* A database user is created to enable MySQL log flushing
* The new database user credentials are saved in a file accessible to the `logrotate` `postrotate` script
* A `logrotate` script is created to effect rotation

#### Properties

* `name` – This has to match the name used for the associated mysql_service instance.
* `mysql_password` – Password for new mysql user created to enable flushing the logs in a postrotate script.
* `connection` – This is a hash of the connection details required to create a new `mysql_database_user`.
    - Please refer to the database cookbook for details.

#### `logrotate` properties

The following properties are passed directly to the `logrotate` cookbook’s `logrotate_app` definition. Note that some of the defaults set here are not the same as for `logrotate_app`, but are intended to create a `logrotate` setup like the default that was created for the old (pre v6) `mysql::server` recipe.

See NOTES for details.

* `rotate, kind_of: Integer, required: false, default: 7`
* `frequency, kind_of: String, required: false, default: 'daily'`
* `dateformat, kind_of: String, required: false, default: nil`
* `size, kind_of: String, required: false, default: nil`
* `maxsize, kind_of: String, required: false, default: nil`
* `logrotate_options, kind_of: Array, required: false, default: ['missingok', 'compress']`

## Usage

```ruby
# assume you have set up a mysql_service
mysql_service 'default' do
  ... # see mysql cookbook >= v6.0 for details
end

# create connection info as an external ruby hash (a la the database cookbook)
mysql_connection_info = {
  host:     '127.0.0.1',
  username: 'root',
  password: 'the_default_service_root_password'
}

# and set up the log rotation for your mysql service
mysql_logrotate_agent 'default' do
  mysql_password 'the_logrotation_password'
  connection     mysql_connection_info
  action         :create
end
```

## What about the default `logrotate` setup that keeps failing?

You can disable the failing default (and unused) MySQL `logrotate` script like so:

```ruby
logrotate_app 'mysql-server' do
  enable false
end
```

We leave it to the operator to do so, as they may have a differently-named default/unused MySQL service.

## NOTES

The "old" setup was verified by standing up a VM using:

* `mysql = 5.6.3`
* `logrotate ~> 1.5`

### Key elements:

The log rotation script was created here:

```bash
-rw-r--r-- 1 root root 847 Jan 21 21:31 /etc/logrotate.d/mysql-server
```

```bash
# - I put everything in one block and added sharedscripts, so that mysql gets
#   flush-logs'd only once.
#   Else the binary logs would automatically increase by n times every day.
/var/log/mysql.log /var/log/mysql/mysql.log /var/log/mysql/mysql-slow.log /var/log/mysql/error.log {
  daily
  rotate 7
  missingok
  create 640 mysql adm
  compress
  sharedscripts
  postrotate
    test -x /usr/bin/mysqladmin || exit 0
    # If this fails, check debian.conf!
    MYADMIN="/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf"
    if [ -z "`$MYADMIN ping 2>/dev/null`" ]; then
      # Really no mysqld or rather a missing debian-sys-maint user?
      # If this occurs and is not a error please report a bug.
      #if ps cax | grep -q mysqld; then
      if killall -q -s0 -umysql mysqld; then
        exit 1
      fi
    else
      $MYADMIN flush-logs
    fi
  endscript
}
```

It depends on the `/etc/mysql/debian.cnf` file, created here:

```bash
-rw------- 1 root root 333 Apr 13 14:27 /etc/mysql/debian.cnf
```

```bash
# Automatically generated for Debian scripts. DO NOT TOUCH!
[client]
host     = localhost
user     = debian-sys-maint
password = AIcdhgzW37q8zOqO
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = debian-sys-maint
password = AIcdhgzW37q8zOqO
socket   = /var/run/mysqld/mysqld.sock
basedir  = /usr
```

#### MySQL privileges

It turns out that the user for the `postrotate` script only needs to "ping" and "flush-logs", and you can do that with just the `USAGE` and `RELOAD` privileges.

## License and Authors

- Author: Tom Wilson @flatrocks
- Author: Jeff Byrnes thejeffbyrnes@gmail.com

[MIT](LICENSE)
