# Inspec test for recipe mysql_logrotate_test::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe file '/etc/mysql-default/logrotator.cnf' do
  its('content') { should include 'password = a_fake_password' }
  its('content') { should include 'host = 127.0.0.1' }
  its('content') { should include 'port = 3306' }
  its('content') { should include 'socket = /var/run/mysql-default/mysqld.sock' }
end

describe file '/etc/mysql-extra/logrotator.cnf' do
  its('content') { should include 'password = a_fake_password' }
  its('content') { should include 'host = 127.0.0.1' }
  its('content') { should include 'port = 3307' }
  its('content') { should include 'socket = /var/run/mysql-extra/mysqld.sock' }
end

describe file '/etc/logrotate.d/mysql-default' do
  its('content') do
    should include '"/var/log/mysql-default/mysql.log" ' \
                                  '"/var/log/mysql-default/mysql-slow.log" ' \
                                  '"/var/log/mysql-default/error.log"'
  end
  its('content') { should include '--defaults-file=/etc/mysql-default/logrotator.cnf' }
  its('content') { should include 'rotate 7' }
  its('content') { should include 'daily' }
  its('content') { should include 'missingok' }
  its('content') { should include ' compress' }
end

describe file '/etc/logrotate.d/mysql-extra' do
  its('content') { should include 'rotate 99' }
  its('content') { should include 'monthly' }
  its('content') { should include 'size 100k' }
  its('content') { should include 'maxsize 100M' }
  its('content') { should include 'dateformat %m%d%Y' }
  its('content') { should include 'nocopytruncate' }
  its('content') { should_not include 'missingok' }
  its('content') { should_not include 'compress' }
end
