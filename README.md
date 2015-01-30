# Galera module

This is a module for installing and confiuring galera.

It depends on the mysql module from puppetlabs as well as xinetd.

## Usage

### galera::server

  Used to deploy and manage a MariaDB Galera server cluster. Installs
  mariadb-galera-server and galera packages, configures galera.cnf and
  starts mysqld service:

    class { 'galera::server':
      mysql_server_hash => {
        override_options        => {
          'mysqld' => {
            'bind-address'           => '0.0.0.0',
            'default-storage-engine' => 'InnoDB',
          }
        },
        package_name            => 'mariadb-galera-cluster',
        service_enabled         => true,
        service_manage          => true,
        root_password           => 'ChangeMe',
        restart                 => false,
        remove_default_accounts => true,
      },
      wsrep_cluster_name => 'galera_cluster',
      wsrep_sst_method   => 'rsync'
      wsrep_sst_username => 'ChangeMe',
      wsrep_sst_password => 'ChangeMe',
    }

### galera::monitor

  Used to monitor a MariaDB Galera cluster server. The class is meant
  to be used in a server load-balancer environment.

    class {'galera::monitor':
      monitor_username => 'mon_user',
      monitor_password => 'mon_pass'
    }

  Here is a sample 3-node HAProxy Configuration:

    listen galera 192.168.220.40:3306
      balance leastconn
      mode    tcp
      option  tcpka
      option  httpchk
      server  control01 192.168.220.41:3306 check port 9200 inter 2000 rise 2 fall 5
      server  control02 192.168.220.42:3306 check port 9200 inter 2000 rise 2 fall 5
      server  control03 192.168.220.43:3306 check port 9200 inter 2000 rise 2 fall 5

## Authors

Daneyon Hansen, Ryan O'Hara
