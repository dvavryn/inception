FROM debian:stable-slim

RUN apt update && apt upgrade && apt install -y php-fpm openssl php-mysqli curl

COPY www.conf /etc/php/8.4/fpm/pool.d/.
COPY script.sh .

RUN chmod +x script.sh

CMD ["./script.sh"]