#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
MYSQL_USER_PASSWORD=$(cat $MYSQL_USER_PASSWORD_FILE)

echo Creating socket directory...
if [ ! -d /run/mysqld ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

if [ ! -d /var/lib/mysql/mysql ]; then
    echo Initializing database...
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

echo Starting MariaDB temporarily...
mysqld --user=mysql --skip-networking &
MYSQL_PID=$!

echo Waiting for MariaDB to be ready...
while ! mysqladmin ping --silent 2>/dev/null; do
    sleep 1
done

if mysql -u root -e "SELECT 1" 2>/dev/null; then
    MYSQL_AUTH="-u root"
else
    MYSQL_AUTH="-u root -p${MYSQL_ROOT_PASSWORD}"
fi

echo Running setup SQL
mysql $MYSQL_AUTH << SQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

echo Setup complete! Stopping MariaDB temporary...
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
wait $MYSQL_PID

echo Starting MariaDB for real...
exec mysqld --user=mysql