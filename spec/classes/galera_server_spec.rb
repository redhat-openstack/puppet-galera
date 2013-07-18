require 'spec_helper'
describe 'galera::server' do
  let :facts do
    { :osfamily => 'Debian' }
  end
  let :params do
    {
      :enabled             => true,
      :manage_service      => true,
      :root_group          => 'root',
      :package_ensure      => 'present',
      :galera_package_name => 'galera',
      :wsrep_package_name  => 'mysql-server-wsrep',
      :libaio_package_name => 'libaio1',
      :libssl_package_name => 'libssl0.9.8',
      :wsrep_deb_name      => 'mysql-server-wsrep-5.5.23-23.6-amd64.deb',
      :wsrep_deb_source    => 'http://launchpad.net/codership-mysql/5.5/5.5.23-23.6/+download/mysql-server-wsrep-5.5.23-23.6-amd64.deb',
      :galera_deb_name     => 'galera-23.2.1-amd64.deb',
      :galera_deb_source   => 'http://launchpad.net/galera/2.x/23.2.1/+download/galera-23.2.1-amd64.deb',
      :wsrep_bind_address  => '0.0.0.0',
      :cluster_name        => 'wsrep',
      :master_ip           => false,
      :wsrep_sst_username  => 'wsrep_user',
      :wsrep_sst_password  => 'wsrep_pass',
      :wsrep_sst_method    => 'mysql_dump'
    }
  end
  it { should contain_package('galera') }
  it { should contain_package('wsrep') }
  it { should contain_package('libaio') }
  it { should contain_package('libssl') }
  it { should contain_file('/etc/mysql/conf.d/wsrep.cnf') }
  it { should contain_service('mysqld') }
end
