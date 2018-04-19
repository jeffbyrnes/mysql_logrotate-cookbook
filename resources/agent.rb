# defaults to match previous implementation of mysql logrotation
default_action :create

# matches instance name of mysql_service
property :name,              String, name_property: true
property :mysql_password,    String,        required: true
property :connection,        Hash,          required: true
# logrotate options.  see logrotate_app docs for details
property :rotate,            Integer,       default: 7
property :frequency,         String,        default: 'daily'
property :dateformat,        [String, nil], default: nil
property :size,              [String, nil], default: nil
property :maxsize,           [String, nil], default: nil
property :logrotate_options, Array,         default: %w(missingok compress sharedscripts)

action :create do
  mysql2_chef_gem 'default'

  mysql_database_user "logrotator for #{new_resource.name}" do
    connection new_resource.connection
    username   'logrotator'
    password   new_resource.mysql_password
    privileges %w(USAGE RELOAD)
    action     %i(create grant)
  end

  template "/etc/mysql-#{new_resource.name}/logrotator.cnf" do
    mode      '600'
    cookbook  'mysql_logrotate'
    variables username: 'logrotator',
              password: new_resource.mysql_password,
              port:     new_resource.connection[:port],
              socket:   new_resource.connection[:socket],
              host:     '127.0.0.1' # always local
  end

  # Specifying sharedscripts as a property of logrotate_app is deprecated,
  #   but we want to ensure it is enabled
  logrotate_opts = if new_resource.logrotate_options.include? 'sharedscripts'
                     new_resource.logrotate_options
                   else
                     (new_resource.logrotate_options << 'sharedscripts')
                   end

  # new_resource is redefined inside logrotate_app b/c it is a Custom Resource
  # This is a bit like JS' that = this silliness
  my = new_resource
  logrotate_app "mysql-#{new_resource.name}" do
    create        '640 mysql adm'
    path          ["/var/log/mysql-#{my.name}/mysql.log",
                   "/var/log/mysql-#{my.name}/mysql-slow.log",
                   "/var/log/mysql-#{my.name}/error.log"]
    options       logrotate_opts
    rotate        my.rotate
    frequency     my.frequency
    dateformat    my.dateformat if my.dateformat
    size          my.size if my.size
    maxsize       my.maxsize if my.maxsize
    postrotate    <<-POSTROTATE
    test -x /usr/bin/mysqladmin || exit 0
    MYADMIN="/usr/bin/mysqladmin --defaults-file=/etc/mysql-#{my.name}/logrotator.cnf"
    if [ -z "`$MYADMIN ping 2>/dev/null`" ]; then
      if killall -q -s0 -umysql mysqld; then
        exit 1
      fi
    else
      $MYADMIN flush-logs
    fi
POSTROTATE
  end
end

# untested !!!
action :delete do
  mysql2_chef_gem 'default'

  mysql_database_user "logrotator for #{new_resource.name}" do
    ignore_failure true
    action         :drop
  end

  template "/etc/mysql-#{new_resource.name}/logrotator.cnf" do
    ignore_failure true
    action         :delete
  end

  template "/etc/logrotate.d/mysql-#{new_resource.name}" do
    ignore_failure true
    action         :delete
  end
end
