#!/bin/bash

set -euxo pipefail

test -f /sal-initial-boot.log && exit 0


cp /etc/environment{,.original}


#/bin/sh /usr/bin/mysqld_safe --log-error=/var/log/mysql/error.log --skip-grant-tables
#
#sal-mysqld --skip-grant-tables <<<"ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}'"
#
#		read -r -d '' rootCreate <<-EOSQL || true
#			CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
#			GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION ;
#		EOSQL
#
#sal-mysqld --skip-grant-tables <<<EOSQL
#ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}';
#
#CREATE USER 'root'@'${SAL__CO_HOSTNAME}' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD}' ;
#GRANT ALL ON "*.*" TO 'root'@'${SAL__CO_HOSTNAME}' WITH GRANT OPTION ;
#
#FLUSH PRIVILEGES ;
#
#EOSQL

#mysql <<<"FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}'; FLUSH PRIVILEGES;"


#MYSQL_PWD="$SAL__MYSQL_ROOT_PWD" mysql <<SQL
#ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}';
#CREATE USER 'root'@'${SAL__CO_HOSTNAME}' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD}' ;
#GRANT ALL ON \*.\* TO 'root'@'${SAL__CO_HOSTNAME}' WITH GRANT OPTION ;
#FLUSH PRIVILEGES ;
#SQL
#
#
#
#MYSQL_PWD="$SAL__MYSQL_ROOT_PWD" mysql <<SQL
#ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}';
#CREATE USER 'root'@'${SAL__CO_HOSTNAME}' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD}' ;
#GRANT ALL ON \*.\* TO 'root'@'${SAL__CO_HOSTNAME}' WITH GRANT OPTION ;
#FLUSH PRIVILEGES ;
#SQL
#
#MYSQL_PWD="$SAL__MYSQL_ROOT_PWD" mysql <<<"ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}'"
#
#
#
