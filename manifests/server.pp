# == Class: galera::server
#
# manages the installation of the galera server.
# manages the package, service, galera.cnf
#
# === Parameters:
#
#  [*bootstrap*]
#   Defaults to false, boolean to set cluster boostrap.
#
#  [*root_password*]
#   Defaults to undef, root password used to bootstrap wsrep.
#   Needed only on first node in wsrep_cluster_members.
#
#  [*package_name*]
#   The name of the galera package.
#
#  [*package_ensure*]
#   Ensure state for package. Can be specified as version.
#
#  [*wsrep_node_address*]
#   Address of local galera node.
#
#  [*wsrep_provider*]
#   Full path to wsrep provider library or 'none'.
#
#  [*wsrep_cluster_name*]
#   Logical cluster name.  be the same for all nodes.
#
#  [*wsrep_cluster_members*]
#   List of cluster members, IP addresses or hostnames.
#
#  [*wsrep_sst_method*]
#   State snapshot transfer method.
#
#  [*wsrep_sst_username*]
#   Username used by the wsrep_sst_auth authentication string.
#
#  [*wsrep_sst_password*]
#   Password used by the wsrep_sst_auth authentication string.
#
#  [*wsrep_ssl*]
#   Boolean to disable SSL even if certificate and key are configured.
#
#  [*wsrep_ssl_key*]
#   Private key for the certificate above, unencrypted, in PEM format.
#
#  [*wsrep_ssl_cert*]
#   Certificate file in PEM format.
#
#  [*debug*]
#
#  [*wsrep_bind_address*]
#   Address to bind galera service.
#
#  [*mysql_server_hash*]
#   Hash of mysql server parameters.
#   Deprecated, please use ::mysql::server class.
#
#
#  [*manage_service*]
#   State of the service.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_name*]
#   The name of the galera service.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_enable*]
#   Defaults to true, boolean to set service enable.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_ensure*]
#   Defaults to running, needed to set root password.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_provider*]
#   What service provider to use.
#   Deprecated, please use ::mysql::server class.
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
# class { 'galera::server':
#   wsrep_cluster_name => 'galera_cluster',
#   wsrep_sst_method   => 'rsync'
#   wsrep_sst_username => 'ChangeMe',
#   wsrep_sst_password => 'ChangeMe',
# }
#
class galera::server (
  $bootstrap             = false,
  $root_password         = undef,
  $debug                 = false,
  $wsrep_node_address    = undef,
  $wsrep_provider        = '/usr/lib64/galera/libgalera_smm.so',
  $wsrep_bind_address    = '0.0.0.0',
  $wsrep_cluster_name    = 'galera_cluster',
  $wsrep_cluster_members = [ $::ipaddress ],
  $wsrep_sst_method      = 'rsync',
  $wsrep_sst_username    = 'root',
  $wsrep_sst_password    = undef,
  $wsrep_ssl             = false,
  $wsrep_ssl_key         = undef,
  $wsrep_ssl_cert        = undef,
  $create_mysql_resource = true,
  # DEPRECATED OPTIONS
  $mysql_server_hash     = {},
  $manage_service        = false,
  $service_name          = 'mariadb',
  $service_enable        = true,
  $service_ensure        = 'running',
)  {
  if $create_mysql_resource {
  warning("DEPRECATED: ::mysql::server should be called manually, please set create_mysql_resource to false and call class ::mysql::server with your config")

    $mysql_server_class = { 'mysql::server' => $mysql_server_hash }

    create_resources( 'class', $mysql_server_class )
  }

  $wsrep_provider_options = wsrep_options({
    'socket.ssl'      => $wsrep_ssl,
    'socket.ssl_key'  => $wsrep_ssl_key,
    'socket.ssl_cert' => $wsrep_ssl_cert,
  })

  $wsrep_debug = bool2num($debug)

  file { '/etc/my.cnf.d/galera.cnf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('galera/wsrep.cnf.erb'),
    notify  => Service['mysqld'],
  }

  if $bootstrap {
    if $wsrep_node_address == $wsrep_cluster_members[0] {
      if $root_password {
        exec 'turn-on-primary':
          onlyif      => "/bin/mysql -sNu root --password=${root_password} -e \"SHOW GLOBAL STATUS WHERE Variable_name='wsrep_cluster_status';\" | /bin/grep 'non-Primary'",
          refreshonly => true,
          command     => "/bin/mysql -sNu root --password=${root_password} -e \"SET GLOBAL wsrep_provider_options='pc.bootstrap=1';\"",
          subscribe   => Service['mysqld'],
          notify      => Class['mysql::server::root_password'],
      } else {
        fail("\$root_password not set for bootstrap")
      }
    } else {
      warning("\$bootstrap was set to true, yet this node \$wsrep_node_address does not seem to be first node in \$wsrep_cluster_members (${wsrep_node_address} != [${wsrep_cluster_members}]0)")
    }
  }

  if $manage_service {
    warning("DEPRECATED: service setup is deprecated, you should use mysql module for this.")
    service { 'galera':
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
