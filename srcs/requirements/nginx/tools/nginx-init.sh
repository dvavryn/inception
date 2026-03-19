#!/bin/bash
set -e

if [ ! -f /etc/nginx/ssl/dvavryn.42.fr.crt ]; then
    echo Generating SSL certificate...
    mkdir /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/dvavryn.42.fr.key \
        -out /etc/nginx/ssl/dvavryn.42.fr.crt \
        -subj "/C=AT/ST=Vienna/L=Vienna/O=42/CN=dvavryn.42.fr"
fi

echo Starting NGINX...
exec nginx -g "daemon off;"