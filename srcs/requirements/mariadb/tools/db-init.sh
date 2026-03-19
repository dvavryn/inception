#!/bin/bash
set -e

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

# echo Running setup SQL
# mysql -u root << SQL
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%';
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# FLUSH PRIVILEGES;
# SQL

if mysql -u root -e "SELECT 1" 2>/dev/null; then
    MYSQL_AUTH="-u root"
else
    MYSQL_AUTH="-u root -proot_password"
fi

echo Running setup SQL
mysql $MYSQL_AUTH << SQL
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'user_password';
GRANT ALL PRIVILEGES ON wordpress.* to 'wp_user'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root_password';
FLUSH PRIVILEGES;
SQL

echo Setup complete! Stopping MariaDB temporary...
mysqladmin -u root -p"root_password" shutdown
wait $MYSQL_PID

echo Starting MariaDB for real...
exec mysqld --user=mysql