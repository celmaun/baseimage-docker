#!/usr/bin/env bash

test -f /sal-initial-boot.log && exit 0

set -euxo pipefail

#mysqld_safe --log-error=/var/log/mysql/error.log --skip-grant-tables --user=mysql &\

#printf 'Temporary MariaDB startup...\n'

#
#sal-mysqld --skip-grant-tables &
#
#while mysqladmin ping --silent; do
#  sleep 1
#  printf '...'
#done
#printf \\n
#
## If root password is $SAL__MYSQL_ROOT_PWD or else...
#if MYSQL_PWD="${SAL__MYSQL_ROOT_PWD:?}" mysql -uroot -e 'SELECT 1;' >/dev/null 2>&1; then :; else
#  mysql -uroot -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '${SAL__MYSQL_ROOT_PWD:?}'; FLUSH PRIVILEGES;"
#fi
#
#printf 'Shutting down MariaDB...\n'
#
#MYSQL_PWD="$SAL__MYSQL_ROOT_PWD" mysqladmin -uroot shutdown
#
#while mysqladmin ping --silent; do
#  sleep 1
#  printf '...'
#done
#printf \\n



date > /sal-initial-boot.log;

