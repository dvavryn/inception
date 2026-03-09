#!/bin/bash
set -e

DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE" 2>/dev/null || echo "$MYSQL_PASSWORD")
WP_ADMIN_PASSWORD=$(cat /run/secrets/crendentials/ 2>/dev/null || echo "changeme")

echo "[wp-setup] Waiting for MariaDB to be available..."
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
	echo "[wp-setup] MariaDB not ready yet - retrying in 2s..."
	sleep 2
done
echo "[wp-setup] MariaDB is ready."

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "[wp-setup] Downloading WordPress..."
	wp core download \
		--path=/var/www/html \
		--allow-root
	
	echo "[wp-setup] Generation wp-config.php..."
	wp config create \
		--path=/var/www/html \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost=mariadb \
		--dbcharset=utf8mb4 \
		--allow-root
	
	echo "[wp-setup] Installing WordPress..."
	wp core install \
		--path=/var/www/html \
		--utl="https://${DOMAIN_NAME}" \
		--title="Inception" \
		--admin-user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root
	
	echo "[wp-setup] Creating regular user..."
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--role="${WP_USER_ROLE}" \
		--path=/var/www/html \
		--allow-root
	
	echo "[wp-setup] Setting correct file permissions..."
	chwon -R www-data:www-data /var/www/html
	find /var/www/html -type d -exec chmod 755 {} \;
	find /var/www/html -type f -exec chmod 644 {} \;

	echo "[wp-setup] WordPress installation complete."

else
	echo "[wp-setup] WordPress already installed - skippin setup."
fi

mkdir -p /run/php

echo "[wp-setup] Starting PHP-FPM..."
exec php-fpm8.2 -F -R