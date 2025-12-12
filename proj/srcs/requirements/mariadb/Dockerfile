FROM debian:trixie

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld

COPY tools/mysql.sh /usr/local/bin
RUN chmod +x /usr/local/bin/mysql.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mysql.sh"]