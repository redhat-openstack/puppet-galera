#
# Class galera::monitor provides in-depth monitoring
# of a MySQL Galera server.
#
# Parameters:
#  [*monitor_username*]    - Username of the service account used for the galera health chck script.
#  [*monitor_password*]    - Password of the service account used for the galera health chck script.
#  [*monitor_hostname*]    - Hostname/IP address that MySQL is bound to. Defaults to 127.0.0.1
#  [*mysql_port]           - Port used by MySQL. Defaults to 3306.
#  [*mysql_bin_dir*]       - Directory path of the mysql binaries.
#  [*mysqlchk_script_dir*] - Directory path used by the galera healthcheck script.
#  [*xinetd_dir*]          - Xinetd directory path used for creating the mysqlchk service.
#  [*enabled*]             - Enable/Disable galera::monitor class.
#
# Actions:
#
# Requires:
# augeas module
#
# Example Usage:
#
#  class {'galera::monitor':
#    monitor_username => 'mon_user',
#    monitor_password => 'mon_pass'
#  }
#
# The galera::monitor is meant to be used in conjunction with HAProxy.
#
# Here is an example HAProxy configuration that implements Galera health checking:
# listen galera 192.168.220.40:3306
#  balance  leastconn
#  mode  tcp
#  option  tcpka
#  option  httpchk
#  server  control01 192.168.220.41:3306 check port 9200 inter 2000 rise 2 fall 5
#  server  control02 192.168.220.42:3306 check port 9200 inter 2000 rise 2 fall 5
#  server  control03 192.168.220.43:3306 check port 9200 inter 2000 rise 2 fall 5
#
class galera::monitor(
  $monitor_username    = 'monitor_user',
  $monitor_password    = 'monitor_pass',
  $monitor_hostname    = '127.0.0.1',
  $mysql_port          = '3306',
  $mysql_bin_dir       = '/usr/bin/mysql',
  $mysqlchk_script_dir = '/usr/local/bin',
  $xinetd_dir 	       = '/etc/xinetd.d',
  $enabled             = true,
) {

  # Needed to manage /etc/services
  include augeas

  Class['galera::server'] -> Class['galera::monitor']

  if $enabled {
    $service_ensure = 'running'
   } else {
    $service_ensure = 'stopped'
  }

  package { 'xinetd':
    ensure  => present,
  }

  service { 'xinetd' :
    ensure      => $service_ensure,
    enable      => $enabled,
    require     => [Package['xinetd'],File["${xinetd_dir}/mysqlchk"]],
    subscribe   => File["${xinetd_dir}/mysqlchk"],
  }

  file { $mysqlchk_script_dir:
    ensure  => directory,
    mode    => '0755',
    require => Package['xinetd'],
    owner   => 'root',
    group   => 'root',
  }

  file { $xinetd_dir:
    ensure  => directory,
    mode    => '0755',
    require => Package['xinetd'],
    owner   => 'root',
    group   => 'root',
  }

  file { "${mysqlchk_script_dir}/galera_chk":
    mode    => '0755',
    require => File[$mysqlchk_script_dir],
    content => template("galera/galera_chk.erb"),
    owner   => 'root',
    group   => 'root',
  }

  file { "${xinetd_dir}/mysqlchk":
    mode    => '0644',
    require => File[$xinetd_dir],
    content => template("galera/mysqlchk.erb"),
    owner   => 'root',
    group   => 'root',
  }

  # Manage mysqlchk service in /etc/services
  augeas { "mysqlchk":
    require => File["${xinetd_dir}/mysqlchk"],
    context =>  "/files/etc/services",
    changes => [
      "ins service-name after service-name[last()]",
      "set service-name[last()] mysqlchk",
      "set service-name[. = 'mysqlchk']/port 9200",
      "set service-name[. = 'mysqlchk']/protocol tcp",
    ],
    onlyif => "match service-name[port = '9200'] size == 0",
  }

  # Create a user for MySQL Galera health check script.
  database_user{ "${monitor_username}@${monitor_hostname}":
    ensure        => present,
    password_hash => mysql_password($monitor_password),
    require       => [File['/root/.my.cnf'],Service['mysqld']],
  }

  database_grant { "${monitor_username}@${monitor_hostname}":
    privileges => [ 'process_priv', 'super_priv' ],
    require    => Database_user["${monitor_username}@${monitor_hostname}"],
  }
}
