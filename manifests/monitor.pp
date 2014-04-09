# Class galera::monitor
#
# Parameters:
#  [*monitor_username*] - Username of the service account used for the galera health chck script.
#  [*monitor_password*] - Password of the service account used for the galera health chck script.
#  [*monitor_hostname*] - Hostname/IP address that galera is bound to. Defaults to 127.0.0.1.
#  [*mysql_port]        - Port used by galera service. Defaults to 3306.
#  [*mysql_path*]       - Full path to database client binary.
#  [*script_dir*]       - Directory where galera healthcheck script is located.
#  [*enabled*]          - Enable/Disable galera::monitor class.
#
# Actions:
#
# Requires:
#
# Sample usage:
# class { 'galera::monitor':
#   monitor_username => 'mon_user',
#   monitor_password => 'mon_pass'
# }
#
class galera::monitor (
  $monitor_username = 'monitor_user',
  $monitor_password = 'monitor_pass',
  $monitor_hostname = '127.0.0.1',
  $mysql_port       = '3306',
  $mysql_path       = '/usr/bin/mysql',
  $script_dir       = '/usr/local/bin',
  $enabled          = true,
) {

  Class['galera::server'] -> Class['galera::monitor']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  file { $script_dir:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

  file { "${script_dir}/galera_chk":
    mode    => '0755',
    require => File[$script_dir],
    content => template("galera/galera_chk.erb"),
    owner   => 'root',
    group   => 'root',
  }

  xinetd::service { 'galera-check':
    port           => '9200',
    server         => "${script_dir}/galera_chk",
    flags          => 'REUSE',
    log_on_failure => 'USERID',
    per_source     => 'UNLIMITED',
  }

  database_user { "${monitor_username}@${monitor_hostname}":
    ensure        => present,
    password_hash => mysql_password($monitor_password),
  }

  database_grant { "${monitor_username}@${monitor_hostname}":
    privileges => [ 'process_priv', 'super_priv' ],
    require    => Database_user["${monitor_username}@${monitor_hostname}"],
  }
}
