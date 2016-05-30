node 'mysql-m1.vinod.local' {
class {'mysql':
server_id => 'server-id = 1',
log_bin  => 'log_bin = /var/log/mysql/mysql-bin.log',
mysql_root_password => 'mysql',
replica_user => 'replicator',
replica_password => 'replicator',
replica_db => 'testdb',
binlog_do_db => 'binlog_do_db = testdb',
bindaddr => '#bind-address = 127.0.0.1',
node_ip => '172.16.20.68',
}
}

node 'mysql-m2.vinod.local' {
#class {'mysql':
#server_id => 'server-id = 2',
#log_bin  => 'log_bin = /var/log/mysql/mysql-bin.log',
#mysql_root_password => 'mysql',
#replica_user => 'replicator',
#replica_password => 'replicator',
#binlog_do_db => 'binlog_do_db = testdb',
#bindaddr => '#bind-address = 127.0.0.1',
#replica_db => 'testdb',
#node_ip => '172.16.20.127',
#}
include userpasswd 
}

node 'mysql-m3.vinod.local' {
class {'mysql':
server_id => 'server-id = 3',
log_bin  => 'log_bin = /var/log/mysql/mysql-bin.log',
mysql_root_password => 'mysql',
replica_user => 'replicator',
replica_password => 'replicator',
binlog_do_db => 'binlog_do_db = testdb',
bindaddr => '#bind-address = 127.0.0.1',
replica_db => 'testdb',
node_ip => '172.16.20.89',
}
}

node 'mysql-m4.vinod.local' {
class {'mysql':
server_id => 'server-id = 4',
log_bin  => 'log_bin = /var/log/mysql/mysql-bin.log',
mysql_root_password => 'mysql',
replica_user => 'replicator',
replica_password => 'replicator',
binlog_do_db => 'binlog_do_db = testdb',
bindaddr => '#bind-address = 127.0.0.1',
replica_db => 'testdb',
node_ip => '172.16.20.127',
}
}
