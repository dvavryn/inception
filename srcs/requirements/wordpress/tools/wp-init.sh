#!/bin/bash
set -e

MYSQL_USER_PASSWORD=$(cat $MYSQL_USER_PASSWORD_FILE)
HOSTNAME=$(cat $CREDENTIALS_FILE | grep hostname | awk '{print $2}')
WP_ADMIN_USER=$(cat $CREDENTIALS_FILE | grep wp_admin_user | awk '{print $2}')
WP_ADMIN_PASSWORD=$(cat $CREDENTIALS_FILE | grep wp_admin_password | awk '{print $2}')
WP_ADMIN_EMAIL=$(cat $CREDENTIALS_FILE | grep wp_admin_email | awk '{print $2}')
WP_USER=$(cat $CREDENTIALS_FILE | grep wp_user_user | awk '{print $2}')
WP_USER_PASSWORD=$(cat $CREDENTIALS_FILE | grep wp_user_password | awk '{print $2}')
WP_USER_EMAIL=$(cat $CREDENTIALS_FILE | grep wp_user_email | awk '{print $2}')

# echo "MYSQLUSERPASSWORD='$MYSQL_USER_PASSWORD'"
# echo "HOSTNAME='$HOSTNAME'"
# echo "WPADMINUSER='$WP_ADMIN_USER'"
# echo "WPADMINPASSWORD='$WP_ADMIN_PASSWORD'"
# echo "WPADMINEMAIL='$WP_ADMIN_EMAIL'"
# echo "WPUSER='$WP_USER'"
# echo "WPUSERPASSWORD='$WP_USER_PASSWORD'"
# echo "WPUSEREMAIL='$WP_USER_EMAIL'"

echo Waiting for MariaDB...
while ! mysqladmin ping -h mariadb -u ${MYSQL_USER} -p${MYSQL_USER_PASSWORD} --silent 2>/dev/null; do
    sleep 2
    echo Try again in 2s
done
echo MariaDB is ready!

if [ ! -f /var/www/html/wp-login.php ]; then
    echo Downloading WordPress...
    wp core download \
        --path=/var/www/html \
        --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    echo Creating wp-config.php
    wp config create \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_USER_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    echo Installing WordPress
    wp core install \
        --path=/var/www/html \
        --url=https://${HOSTNAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    echo Creating second user...
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --path=/var/www/html \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root

    echo WordPress setup complete!
fi

echo Starting php-fpm
exec php-fpm8.2 -F