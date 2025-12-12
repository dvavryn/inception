#!/bin/bash

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html

echo "Waiting for MariaDB"
while ! mariadb -h mariadb -u$SQL_USER -p$SQL_PASSWORD $SQL_DATABASE &>/dev/null; do
	sleep 3
done
echo "MariaDB is up now!"


if [ ! -f "wp-config.php" ]; then
	wp core download --allow-root

	wp config create \
		--dbname=$SQL_DATABASE \
		--dbuser=$SQL_USER \
		--dbpass=$SQL_PASSWORD \
		--dbhost=mariadb:3306 \
		--allow-root

	wp core install \
		--url=$DOMAIN_NAME \
		--title=$SITE_TITLE \
		--admin-user=$ADMIN_USER \
		--admin-password=$ADMIN_PASSWORD \
		--allow-root

	wp user creat \
		$USER1_LOGIN \
		$USER1_EMAIl \
		--role=author \
		--user_pass=$USER1_PASS \
		--allow-root
fi

exec /usr/sbin/php-fpm8.4 -F