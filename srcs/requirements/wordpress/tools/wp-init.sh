#!/bin/bash
set -e

echo Waiting for MariaDB...
while ! mysqladmin ping -h mariadb -u wp_user -puser_password --silent 2>/dev/null; do
    sleep 2
    echo Try again in 2s
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
        --dbname=wordpress \
        --dbuser=wp_user \
        --dbpass=user_password \
        --dbhost=mariadb:3306 \
        --allow-root

    echo Installing WordPress
    wp core install \
        --path=/var/www/html \
        --url=https://dvavryn.42.fr \
        --title="Inception" \
        --admin_user=dvavryn \
        --admin_password=dvavryn \
        --admin_email=dvavryn@dvavryn.42.fr \
        --allow-root

    echo Creating second user...
    wp user create bschwarz bschwarz@dvavryn.42.fr \
        --path=/var/www/html \
        --user_pass=bschwarz \
        --role=author \
        --allow-root

    echo WordPress setup complete!
fi

echo Starting php-fpm
exec php-fpm8.2 -F