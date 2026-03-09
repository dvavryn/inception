#!/bin/bash
set -e

DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE" 2>/dev/null || echo "$MYSQL_PASSWORD")
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE" 2>/dev/null || echo "$MYSQL_ROOT_PASSWORD")

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[init] Fresh volume detected - initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null

	echo "[init] Starting temporary MariaDB instance for setup..."
	mysqld_safe --skip-networking &
	TEMP_PID=$!

	echo "[init] Waiting for MariaDB to be ready..."
	until mysqladmin ping --silent 2>/dev/null; do
		sleep 1
	done

	echo "[init] Running setup queries..."
	mysql -u root << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM musql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
ALTER USER 'roor'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	echo "[init] Setup complete. Shutting down temporary instance..."
	mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
	wait $TEMP_PID
	echo "[init] Temporary instance stopped."
else
	echo "[init] Existing data directory found - skipping initialization."
fi

echo "[init] Starting MariaDB in foreground..."
exec mysqld --user=mysql