FROM debian:stable-slim

RUN apt update && apt upgrade && apt install nginx -y

COPY default /etc/nginx/sites-available/.
COPY ssl /etc/nginx/ssl
CMD ["nginx", "-g", "daemon off;"]