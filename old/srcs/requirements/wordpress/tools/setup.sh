#!/bin/bash
set -e

echo Waiting for MariaDB...
while ! mysqladmin ping -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --silent 2>/dev/null; do
	sleep 2
done
echo MariaDB is ready!


if [ ! -f /var/www/html/wp-config.php ]; then
	echo Downloading WordPress...
	wp core download \
		--path=/var/www/html \
		--allow-root
	
	echo Creating wp-config.php
	wp config create \
		--path=/var/www/html \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--dbhost=mariadb:3306 \
		--allow-root
	
	echo Installing WordPress
	wp core install \
		--path=/var/www/html \
		--url=https://${DOMAIN_NAME} \
		--title="Inception" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--allow-root
	
	echo Creation second user...
	wp user create ${WP_USER} ${WP_USER_EMAIL} \
		--path=/var/www/html \
		--user_pass=${WP_USER_PASSWORD} \
		--role=author \
		--allow-root
	
	echo Wordpress setup complete!
fi

echo Starting php-fpm
exec php-fpm8.2 -F