require 'spec_helper'

describe 'galera::server', :type => :class do

  let :facts do
    { :osfamily => 'RedHat' }
  end

  let :params do
    {
      :bootstrap             => false,
      :wsrep_bind_address    => '0.0.0.0',
      :wsrep_node_address    => 'undef',
      :wsrep_provider        => '/usr/lib64/galera/libgalera_smm.so',
      :wsrep_cluster_name    => 'galera_cluster',
      :wsrep_cluster_members => ['127.0.0.1'],
      :wsrep_sst_method      => 'rsync',
      :wsrep_sst_username    => 'root',
      :wsrep_sst_password    => 'undef',
      :wsrep_ssl             => false,
      :wsrep_ssl_key         => 'undef',
      :wsrep_ssl_cert        => 'undef',
      :debug                 => false,
    }
  end

  it { should contain_class('mysql::server') }

  context 'Configures /etc/my.cnf.d/galera.cnf' do
    it { should contain_file('/etc/my.cnf.d/galera.cnf').with(
      'ensure' => 'present',
      'mode'   => '0644',
      'owner'  => 'root',
      'group'  => 'root',
      'before' => 'Service[mysqld]'
      )
    }
  end
end
