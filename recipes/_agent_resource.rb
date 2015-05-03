Chef::Log.warn "This recipe is intended only for testing the mysql_logrotate_agent resource"

mysql_logrotate_agent 'default' do
  mysql_password 'a_fake_password'
  connection host: '127.0.0.1', port: '3306', username: 'root', password: 'fake_root_password', socket: '/socket1'
end

mysql_logrotate_agent 'extra' do
  mysql_password 'a_fake_password'
  connection host: '127.0.0.1', port: '3306', username: 'root', password: 'fake_root_password', socket: '/socket1'
  rotate 99
  frequency 'monthly'
  dateformat '%m%d%Y'
  size '100k'
  maxsize '100M'
  logrotate_options ['nocopytruncate']
end
