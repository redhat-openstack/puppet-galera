# Class: galera::server
#
# manages the installation of the galera server.
# manages the package, service, galera.cnf
#
# Parameters:
#  [*config_hash*]           - Hash of config parameters that need to be set.
#  [*enabled*]               - Defaults to true, boolean to set service ensure.
#  [*manage_service*]        - Boolean dictating if galera::server should manage the service.
#  [*package_ensure*]        - Ensure state for package. Can be specified as version.
#  [*package_name*]          - The name of the galera package.
#  [*service_name*]          - The name of the galera service.
#  [*service_provider*]      - What service provider to use.
#  [*wsrep_bind_address*]    - Address to bind galera service.
#  [*wsrep_provider*]        - Full path to wsrep provider library or 'none'.
#  [*wsrep_cluster_name*]    - Logical cluster name. Should be the same for all nodes.
#  [*wsrep_cluster_address*] - Group communication system handle.
#  [*wsrep_sst_method*]      - State snapshot transfer method.
#  [*wsrep_sst_username*]    - Username used by the wsrep_sst_auth authentication string.
#  [*wsrep_sst_password*]    - Password used by the wsrep_sst_auth authentication string.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# class { 'galera::server':
#   config_hash => {
#     'root_password' => 'root_pass',
#   },
#   cluster_name       => 'galera_cluster',
#   wsrep_sst_method   => 'rsync'
#   wsrep_sst_username => 'ChangeMe',
#   wsrep_sst_password => 'ChangeMe',
# }
#
class galera::server (
  $config_hash           = {},
  $enabled               = true,
  $manage_service        = true,
  $package_ensure        = 'present',
  $package_name          = 'mariadb-galera-server',
  $service_name          = $mysql::params::service_name,
  $service_provider      = $mysql::params::service_provider,
  $wsrep_bind_address    = '0.0.0.0',
  $wsrep_provider        = '/usr/lib64/galera/libgalera_smm.so',
  $wsrep_cluster_name    = 'galera_cluster',
  $wsrep_cluster_address = 'gcomm://',
  $wsrep_sst_method      = 'rsync',
  $wsrep_sst_username    = 'root',
  $wsrep_sst_password    = undef,
) inherits mysql {

  $config_class = { 'mysql::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { 'galera':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { '/etc/my.cnf.d/galera.cnf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('galera/wsrep.cnf.erb'),
    notify  => Service['galera'],
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $manage_service {
    Service['galera'] -> Exec<| title == 'set_mysql_rootpw' |>

    service { 'galera':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $enabled,
      require  => Package['galera'],
      provider => $service_provider,
    }
  }
}
