# == Class: galera::server
#
# manages the installation and configuration of the galera server and galera.cnf
#
# === Parameters:
#
#  [*mysql_server_hash*]
#   Hash of mysql server parameters.
#
#  [*bootstrap*]
#   Defaults to false, boolean to set cluster boostrap.
#
#  [*wsrep_bind_address*]
#   Address to bind galera service.
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
# === Actions:
#
# === Requires:
#
# === Sample Usage:
# class { 'galera::server':
#   mysql_server_hash => {
#     override_options        => {
#       'mysqld' => {
#         'bind-address'           => '0.0.0.0',
#         'default-storage-engine' => 'InnoDB',
#       }
#     },
#     package_name            => 'mariadb-galera-cluster',
#     service_enabled         => true,
#     service_manage          => true,
#     root_password           => 'ChangeMe',
#     restart                 => false,
#     remove_default_accounts => true,
#   },
#   wsrep_cluster_name => 'galera_cluster',
#   wsrep_sst_method   => 'rsync'
#   wsrep_sst_username => 'ChangeMe',
#   wsrep_sst_password => 'ChangeMe',
# }
#
class galera::server (
  $mysql_server_hash     = {},
  $bootstrap             = false,
  $wsrep_bind_address    = '0.0.0.0',
  $wsrep_node_address    = undef,
  $wsrep_provider        = '/usr/lib64/galera/libgalera_smm.so',
  $wsrep_cluster_name    = 'galera_cluster',
  $wsrep_cluster_members = [],
  $wsrep_sst_method      = 'rsync',
  $wsrep_sst_username    = 'root',
  $wsrep_sst_password    = undef,
  $wsrep_ssl             = false,
  $wsrep_ssl_key         = undef,
  $wsrep_ssl_cert        = undef,
  $debug                 = false,
)  {

  $mysql_server_class = { 'mysql::server' => $mysql_server_hash }

  create_resources( 'class', $mysql_server_class )

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
    before  => Service['mysqld'],
  }
}
