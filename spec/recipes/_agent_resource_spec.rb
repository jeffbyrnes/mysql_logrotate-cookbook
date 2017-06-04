require 'spec_helper'

describe "mysql_logrotate::_agent_resource" do

  subject { ChefSpec::SoloRunner.new(:step_into => ['mysql_logrotate_agent']) do |node|
  end.converge(described_recipe) }
  let(:expected_connection) {{
    host: "127.0.0.1",
    username: 'root',
    password: 'fake_root_password',
    port: '3306',
    socket: '/socket1'
  }}

  describe "the database_user" do
    it { is_expected.to create_mysql_database_user("logrotator for default") }
    it { is_expected.to create_mysql_database_user("logrotator for default").with_connection expected_connection }
    it { is_expected.to create_mysql_database_user("logrotator for default").with_username 'logrotator' }
    it { is_expected.to create_mysql_database_user("logrotator for default").with_password 'a_fake_password' }
  end

  describe "the database_user privileges" do
    it { is_expected.to grant_mysql_database_user("logrotator for default").with_privileges ["USAGE", "RELOAD"] }
  end

  describe "the logrotator.cnf file" do
    it { is_expected.to create_template("/etc/mysql-default/logrotator.cnf") }
    it { is_expected.to render_file("/etc/mysql-default/logrotator.cnf").with_content('user = logrotator') }
    it { is_expected.to render_file("/etc/mysql-default/logrotator.cnf").with_content('password = a_fake_password') }
    it { is_expected.to render_file("/etc/mysql-default/logrotator.cnf").with_content('host = 127.0.0.1') }
    it { is_expected.to render_file("/etc/mysql-default/logrotator.cnf").with_content('port = 3306') }
    it { is_expected.to render_file("/etc/mysql-default/logrotator.cnf").with_content('socket = /socket1') }
  end

  context 'with default options' do
    describe "the logrotate script file" do
      it { is_expected.to create_template("/etc/logrotate.d/mysql-default") }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content('"/var/log/mysql-default/mysql.log" "/var/log/mysql-default/mysql-slow.log" "/var/log/mysql-default/error.log"') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content('--defaults-file=/etc/mysql-default/logrotator.cnf') }

      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content('rotate 7') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content('daily') }
      it { is_expected.to_not render_file("/etc/logrotate.d/mysql-default").with_content('size') }
      it { is_expected.to_not render_file("/etc/logrotate.d/mysql-default").with_content('maxsize') }
      # options
      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content('missingok') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-default").with_content(' compress') }
    end
  end

  context 'with optional settings' do
    describe "the logrotate script file" do
      it { is_expected.to create_template("/etc/logrotate.d/mysql-extra") }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('rotate 99') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('monthly') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('size 100k') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('maxsize 100M') }
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('dateformat %m%d%Y') }
      # options
      it { is_expected.to render_file("/etc/logrotate.d/mysql-extra").with_content('nocopytruncate') }
      # when set, options do not include defaults
      it { is_expected.not_to render_file("/etc/logrotate.d/mysql-extra").with_content('missingok') }
      it { is_expected.not_to render_file("/etc/logrotate.d/mysql-extra").with_content('compress') }
    end
  end
end