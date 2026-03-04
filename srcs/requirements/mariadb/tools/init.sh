#!/bin/bash
set -e

echo Creating socket directory...
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

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

echo Running setup SQL...
mysql -u root << SQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

echo Setup complete! Stopping temporary MariaDB...
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
wait $MYSQL_PID

echo Starting MariaDB for real
exec mysqld --user=mysql

# #!/bin/bash
# set -e

# mkdir -p /run/mysqld
# chown -R mysql:mysql /run/mysqld

# if [ ! -d /var/lib/mysql/mysql ]; then
#     echo Inititialising database...
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

#     running bootstrap SQL...
#     mysqld --user=mysql --bootstrap << SQL
# FLUSH PRIVILEGES;
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${MySQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# FLUSH PRIVILEGES;
# SQL
#     echo Bootstrap complete!
# else
#     echo Database already initialized, skipping setup...
# fi

# echo Starting MariaDB
# exec mysqld --user=mysql
