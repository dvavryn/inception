FROM debian:bookworm

RUN apt-get update && apt install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/inception.conf
COPY tools/nginx-init.sh /nginx-init.sh

RUN ln -s /etc/nginx/sites-available/inception.conf /etc/nginx/sites-enabled/inception.conf \
    && rm -f /etc/nginx/sites-enabled/default
    
RUN chmod +x /nginx-init.sh

EXPOSE 443

CMD ["/nginx-init.sh"]