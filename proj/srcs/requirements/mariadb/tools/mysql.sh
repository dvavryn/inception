#!/bin/bash

service mariadb start

sleep 5

if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then

	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
	mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
	mariadb -e "FLUSH PRIVILEGES;"
	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
else
	echo "Database already exists. Skipping setup."
fi

mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

exec mysqld