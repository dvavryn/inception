#!/bin/bash

mkdir -p srcs/requirements
cd srcs/requirements
touch docker-compose.yml .env

mkdir -p nginx/conf nginx/tools
touch nginx/conf/nginx.cnf nginx/tools/nginx_setup.sh

mkdir -p mariadb/conf mariadb/tools
touch mariadb/conf/mariadb.cnf mariadb/tools/mariadb_setup.sh

mkdir -p wordpress/conf wordpress/tools
touch wordpress/conf/wordpress.cnf wordpress/tools/wordpress_setup.sh

touch nginx/Dockerfile mariadb/Dockerfile wordpress/Dockerfile
