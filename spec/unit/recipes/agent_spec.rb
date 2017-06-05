require 'spec_helper'

describe 'mysql_logrotate_test::default' do
  context 'When all properties are default, on Ubuntu 16.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(step_into: ['mysql_logrotate_agent']).converge described_recipe
    end

    let(:expected_connection) do
      {
        host:     '127.0.0.1',
        username: 'root',
        password: 'fake_root_password',
        port:     '3306',
        socket:   '/var/run/mysql-default/mysqld.sock',
      }
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a database_user' do
      expect(chef_run).to create_mysql_database_user('logrotator for default').with(
        connection: expected_connection,
        username:   'logrotator',
        password:   'a_fake_password'
      )
    end

    it 'sets the database_user privileges' do
      expect(chef_run).to grant_mysql_database_user('logrotator for default').with_privileges %w(USAGE RELOAD)
    end

    it 'creates the logrotator.cnf file' do
      expect(chef_run).to create_template('/etc/mysql-default/logrotator.cnf')
      expect(chef_run).to render_file('/etc/mysql-default/logrotator.cnf').with_content('user = logrotator')
      expect(chef_run).to render_file('/etc/mysql-default/logrotator.cnf').with_content('password = a_fake_password')
      expect(chef_run).to render_file('/etc/mysql-default/logrotator.cnf').with_content('host = 127.0.0.1')
      expect(chef_run).to render_file('/etc/mysql-default/logrotator.cnf').with_content('port = 3306')
      expect(chef_run).to render_file('/etc/mysql-default/logrotator.cnf').with_content('socket = /var/run/mysql-default/mysqld.sock')
    end

    it 'enables logrotation' do
      expect(chef_run).to enable_logrotate_app('mysql-default').with(
        create: '640 mysql adm',
        path:   ['/var/log/mysql-default/mysql.log',
                 '/var/log/mysql-default/mysql-slow.log',
                 '/var/log/mysql-default/error.log']
      )
    end

    it 'enables logrotation with optional settings' do
      expect(chef_run).to enable_logrotate_app('mysql-extra').with(
        create:     '640 mysql adm',
        path:       ['/var/log/mysql-extra/mysql.log',
                     '/var/log/mysql-extra/mysql-slow.log',
                     '/var/log/mysql-extra/error.log'],
        rotate:     99,
        frequency:  'monthly',
        dateformat: '%m%d%Y',
        size:       '100k',
        maxsize:    '100M',
        options:    %w(nocopytruncate sharedscripts)
      )
    end
  end
end
