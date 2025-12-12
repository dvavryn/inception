FROM debian:trixie

RUN apt-get update && apt-get install -y \
	php8.4 \
	php8.4-fpm \
	php8.4-mysql \
	mariadb-client \
	wget \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

RUN mkdir -p /run/php

COPY tools/wordpress.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]