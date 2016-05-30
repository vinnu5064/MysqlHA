class mysql ( $mysql_root_password, $replica_user, $replica_password, $server_id, $log_bin, $replica_db, $binlog_do_db, $bindaddr, $node_ip ) {



exec { 'update':
command => 'apt-get update',
path    => '/usr/bin/',
}

package { 'mysql-server': ensure => 'installed', require => Exec['update'], }
package { 'mysql-client': ensure => 'installed',  require => Exec['update'], }


service { 'mysql': enable => 'true', ensure => 'running', require => Exec['update'],}

exec { 'set-mysql-password':
unless  => "mysqladmin -uroot -p$mysql_root_password status",
path    => ["/bin", "/usr/bin"],
command => "mysqladmin -uroot password $mysql_root_password",
require => Service["mysql"],
}

file { '/etc/mysql/my.cnf':
ensure    => present,
}->
file_line { 'changing server id':
  path    => '/etc/mysql/my.cnf',
  line    => $server_id,
  match   => "^#server-id.*$",
}
file_line { 'changing log_bin':
  path    => '/etc/mysql/my.cnf',
  line    => $log_bin,
  match   => "^#log_bin.*$",
}

file_line { 'select db':
  path    => '/etc/mysql/my.cnf',
  line    => $binlog_do_db,
  match   => "^#binlog_do_db.*$",
}
file_line { 'bindaddr':
  path    => '/etc/mysql/my.cnf',
  line    => $bindaddr,
  match   => "^bind-address.*$",
  notify  => Service["mysql"],
  require => [ Package['mysql-server'], Package['mysql-client'] ],
}

exec { 'create-replica-user':
unless  => "mysqladmin -u$replica_user -p$replica_password status",
command => "mysql --user=root --password=$mysql_root_password -e \"create user '${replica_user}'@'%' identified by '$replica_password';\"",
path    => ["/bin", "/usr/bin"],
require => [ File ['/etc/mysql/my.cnf'], Exec['set-mysql-password']],
}

#exec{ 'drop-passwordless-user':
#command => "mysql --user=root --password=$mysql_root_password -e \"delete from mysql.user where password='' and host='$node_ip' and user='root'\"",
#path => ["/bin", "/usr/bin"],
#}


#exec { 'creating-root-from-host':
#unless => "mysql --user=root --password=mysql -e \"select user,host from mysql.user where host='$node_ip' and user='root' and password IS NULL\"",
#command => "mysql --user=root --password=$mysql_root_password -e \"create user 'root'@'$node_ip' identified by '$mysql_root_password';\"",
#path => ["/bin", "/usr/bin"],
#require => [ Exec ['drop-passwordless-user'], Exec ['set-mysql-password']],
#}






exec { 'granting-root-privileges':

#mysql --user=root --password=mysql -e "grant all privileges on *.* to 'root'@'172.16.20.127' identified by password '`mysql --user=root --password=mysql -e "select password from mysql.user where host='mysql-m3.vinod.local'"|tail -n 1`'"

command => "mysql --user=root --password=$mysql_root_password -e \"grant all privileges on *.* to 'root'@'$node_ip' identified by password '`mysql --user=root --password=mysql -e \"select password from mysql.user where host='$node_ip'\"|tail -n 1`'\"",
path => ["/bin","/usr/bin"],
#require => Exec ['creating-root-from-host'],
}


exec { 'create-replica-db':
unless  => "mysql --user=root --password=$mysql_root_password -e \"use $replica_db"",
command => "mysql --user=root --password=$mysql_root_password -e \"create database $replica_db;\"",
path    => ["/bin",  "/usr/bin"],
require => [ Exec ['set-mysql-password'], Exec['create-replica-user'] ],
}

exec { 'grant-db-root':
command => "mysql --user=root --password=$mysql_root_password -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;\"",
path    => ["/bin", "/usr/bin"],
require => Exec ['set-mysql-password']
}

exec { 'grant-db-replica':
command => "mysql --user=root --password=$mysql_root_password -e \"GRANT REPLICATION SLAVE ON *.* TO '${replica_user}'@'%' IDENTIFIED BY '$replica_password';\"",
path    => ["/bin", "/usr/bin"],
require => Exec['create-replica-user'],
}

exec { 'slave-stop':
command => "mysql --user=root --password=$mysql_root_password -e \"slave stop;\"",
path    => ["/bin", "/usr/bin"],
require => [Exec['create-replica-user'], Exec['create-replica-db'], Exec['grant-db-replica']]
}




exec { 'changing-as-master':
#command => "ls",
command => "mysql --user=root --password=$mysql_root_password -e \"CHANGE MASTER TO MASTER_HOST = '$node_ip', MASTER_USER = '$replica_user', MASTER_PASSWORD = '$replica_password', MASTER_LOG_FILE = '`mysql --user=root --password='' --host=$node_ip -e \"show master status\"|awk '{print \$1}'|tail -n 1`', MASTER_LOG_POS = `mysql --user=root --password='' --host=$node_ip -e \"show master status\"|awk '{print \$2}'|tail -n 1`;\"",




path    => ["/bin", "/usr/bin"],
require => [Exec ['grant-db-root'], Exec['create-replica-user'], Exec ['slave-stop']],
}

exec { 'slave-start':
command => "mysql --user=root --password=$mysql_root_password -e \"slave start;\"",
path    => ["/bin", "/usr/bin"],
require => Exec['changing-as-master']
}




}
