require 'spec_helper'
describe 'galera::server' do
  let :facts do
    { :osfamily => 'RedHat' }
  end
  let :params do
    {
      :enabled               => true,
      :manage_service        => true,
      :package_ensure        => 'present',
      :package_name          => 'mariadb-galera-server',
      :service_name          => 'mariadb',
      :wsrep_bind_address    => '0.0.0.0',
      :wsrep_provider        => '/usr/lib64/galera/libgalera_smm.so',
      :wsrep_cluster_name    => 'galera_cluster',
      :wsrep_cluster_address => 'gcomm://',
      :wsrep_sst_method      => 'rsync',
      :wsrep_sst_username    => 'wsrep_user',
      :wsrep_sst_password    => 'wsrep_pass',
    }
  end

  it { should contain_package('galera')}
  it { should contain_file('/etc/my.cnf.d/galera.cnf')}
  it { should contain_service('galera')}

end
