require 'spec_helper'
describe 'galera::monitor' do
  let :facts do
    { :osfamily => 'Debian' }
  end
  let :pre_condition do
    "include 'galera::server'"
  end
  let :params do
    {
      :monitor_username    => 'monitor_user',
      :monitor_password    => 'monitor_pass',
      :monitor_hostname    => '127.0.0.1',
      :mysql_port          => '3306',
      :mysql_bin_dir       => '/usr/bin/mysql',
      :mysqlchk_script_dir => '/usr/local/bin',
      :xinetd_dir          => '/etc/xinetd.d',
      :enabled             => true
    }
  end

  it { should contain_service('xinetd').with(
    :ensure   => 'running',
    :enable   => 'true'
    )}

  it { should contain_file('/usr/local/bin/galera_chk')}
  it { should contain_file('/etc/xinetd.d/mysqlchk')}
  it { should contain_database_user("monitor_user@127.0.0.1")}

end
