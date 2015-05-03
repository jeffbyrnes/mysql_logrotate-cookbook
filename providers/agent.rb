use_inline_resources

def whyrun_supported?
  true  # uses only platform providers
end

action :create do

  mysql_database_user "logrotator for #{new_resource.name}" do
    connection new_resource.connection
    username "logrotator"
    password new_resource.mysql_password
    privileges ['USAGE', 'RELOAD']
    action [:create, :grant]
  end

  template "/etc/mysql-#{new_resource.name}/logrotator.cnf" do
    owner 'root'
    group 'root'
    mode "600"
    source "logrotator.cnf.erb"
    cookbook "mysql_logrotate"
    variables username: "logrotator",
      password: new_resource.mysql_password,
      port: new_resource.connection[:port],
      socket: new_resource.connection[:socket],
      host: '127.0.0.1' # always local
    action :create
  end

  my = new_resource # new_resource is redefined inside this definition somehow
  logrotate_app "mysql-#{new_resource.name}" do
    compress  true
    sharedscripts true
    create    '640 mysql adm'
    postrotate postrotate
    path ["/var/log/mysql-#{my.name}/mysql.log", "/var/log/mysql-#{my.name}/mysql-slow.log", "/var/log/mysql-#{my.name}/error.log"]
    options   my.logrotate_options
    postrotate <<-POSTROTATE
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
    # configurable
    rotate my.rotate
    frequency my.frequency
    dateformat my.dateformat if my.dateformat
    size my.size if my.size
    maxsize my.maxsize if my.maxsize
  end

end

action :delete do
  # untested !!!
  mysql_database_user "logrotator for #{new_resource.name}" do
    ignore_failure true
    action :drop
  end

  template "/etc/mysql-#{new_resource.name}/logrotator.cnf" do
    ignore_failure true
    action :delete
  end

  template "/etc/logrotate.d/mysql-#{new_resource.name}" do
    ignore_failure true
    action :delete
  end
end

def load_current_resource
  @current_resource = Chef::Resource::MysqlLogrotateAgent.new(new_resource.name)

  @current_resource.name(new_resource.name)
  @current_resource.mysql_password(new_resource.mysql_password)
  @current_resource.connection(new_resource.connection)

  @current_resource.rotate(new_resource.rotate)
  @current_resource.frequency(new_resource.frequency)
  @current_resource.dateformat(new_resource.dateformat)
  @current_resource.size(new_resource.size)
  @current_resource.maxsize(new_resource.maxsize)
  @current_resource.logrotate_options(new_resource.logrotate_options)

  @current_resource
end