#
# Cookbook Name:: mysql_logrotate_test
# Recipe:: default
#

mysql_service 'default' do
  version               '5.7'
  initial_root_password 'fake_root_password'
  action                %i(create start)
end

mysql_service 'extra' do
  version               '5.7'
  port                  '3307'
  initial_root_password 'fake_root_password'
  action                %i(create start)
end

mysql_logrotate_agent 'default' do
  mysql_password 'a_fake_password'
  connection     host:     '127.0.0.1',
                 port:     '3306',
                 username: 'root',
                 password: 'fake_root_password',
                 socket:   '/var/run/mysql-default/mysqld.sock'
end

mysql_logrotate_agent 'extra' do
  mysql_password    'a_fake_password'
  connection        port:     '3307',
                    username: 'root',
                    password: 'fake_root_password',
                    socket:   '/var/run/mysql-extra/mysqld.sock'
  rotate            99
  frequency         'monthly'
  dateformat        '%m%d%Y'
  size              '100k'
  maxsize           '100M'
  logrotate_options %w(nocopytruncate)
end
