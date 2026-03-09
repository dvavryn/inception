FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
	nginx \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/inception
COPY tools/setup.sh /setup.sh

RUN ln -s /etc/nginx/sites-available/inception /etc/nginx/sites-enabled/inception \
    && chmod +x /setup.sh

EXPOSE 443

CMD ["/setup.sh"]