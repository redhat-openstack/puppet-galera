# Gelera module

This is a module for installing galera.

It depends on the mysql module from puppetlabs as
well as augeas.


## Usage

### mysql::server::galera

Used to deploy and manage a MySQL Galera server cluster.
Installs wsrep and galera packages, configures wsrep.cnf and starts mysqld service:

  class { 'mysql::server::galera':
    config_hash => {
      'root_password' => 'root_pass',
    },
    cluster_name       => 'galera_cluster',
    master_ip          => false,
    wsrep_sst_username => 'ChangeMe',
    wsrep_sst_password => 'ChangeMe',
    wsrep_sst_method   => 'rsync'
  }

### mysql::server::galera::monitor

  Used to monitor a MySQL Galera clustered server.
  The class is meant to be used in a server load-balancer environment.

    class {'mysql::server::galera::monitor':
      monitor_username => 'mon_user',
      monitor_password => 'mon_pass'
    }

Here is a sample 3-node HAProxy Configuration:

  listen galera 192.168.220.40:3306
   balance  leastconn
   mode  tcp
   option  tcpka
   option  httpchk
   server  control01 192.168.220.41:3306 check port 9200 inter 2000 rise 2 fall 5
   server  control02 192.168.220.42:3306 check port 9200 inter 2000 rise 2 fall 5
   server  control03 192.168.220.43:3306 check port 9200 inter 2000 rise 2 fall 5


## Author

Daneyon Hansen
