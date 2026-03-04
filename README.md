1. Setup:
    - Setup a new VM prefered Debian and update it
        sudo apt update && sudo apt upgrade
    - Install curl git make and vim
        sudo apt install -y curl git make vim
            curl - needed to download Docker's install script
            git - to manage the projects repo
            make - to run the makefile later
            vim - text editor
    - Install Docker
        curl -fsSL http://get.docker.com -o get-docker.sh
        sh get-docker.sh
            // official Docker install script
    - Add User to docker group to not need to use sudo all the time
        sudo usermod -aG docker $USER

2. Verify everything works
    docker --version
    docker compose --version
    git --version
    make --version

3. Create project structure
    mkdir -p ~/inception/srcs/requirements/nginx/conf
    mkdir -p ~/inception/srcs/requirements/nginx/tools
    mkdir -p ~/inception/srcs/requirements/wordpress/conf
    mkdir -p ~/inception/srcs/requirements/wordpress/tools
    mkdir -p ~/inception/srcs/requirements/mariadb/conf
    mkdir -p ~/inception/srcs/requirements/mariadb/tools
    mkdir -p ~/inception/secrets

4. Create empty files to fill later
    touch ~/inception/Makefile
    touch ~/inception/srcs/docker-compose.yml
    touch ~/inception/srcs/.env
    touch ~/inception/srcs/requirements/nginx/Dockerfile
    touch ~/inception/srcs/requirements/wordpress/Dockerfile
    touch ~/inception/srcs/requirements/mariadb/Dockerfile

5. create secrets files
    echo "Dominic1999" > ~/inception/secrets/db_password.txt
    echo "Dominic1999" > ~/inception/secrets/db_root_password.txt

6. Create a .gitignore
    cat > ~/inception/.gitignore << 'EOF'
    secrets/
    srcs/.env
    EOF

7. Verify structure with tree
    inception/
    ├── .gitignore
    ├── Makefile
    ├── README.md
    ├── secrets
    │   ├── db_password.txt
    │   └── db_root_password.txt
    └── srcs
        ├── .env
        ├── docker-compose.yml
        └── requirements
            ├── mariadb
            │   ├── conf
            │   ├── Dockerfile
            │   └── tools
            ├── nginx
            │   ├── conf
            │   ├── Dockerfile
            │   └── tools
            └── wordpress
                ├── conf
                ├── Dockerfile
                └── tools

8. Fill .env file
cat > ~/inception/srcs/.env << EOF
# Domain
DOMAIN_NAME=dvavryn.42.fr

# MYSQL
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=your_db_password
MYSQL_ROOTPASSWORD=your_db_root_password

# WordPress
WP_ADMIN_USER=dvavryn
WP_ADMIN_PASSWORD=Dominic1999
WP_ADMIN_EMAIL=dvavryn@42.fr
WP_USER=dvavryn_usr
WP_USER_PASSWORD=Dominic1999
WP_USER_EMAIL=dvavryn_usr@42.fr
EOF

9. Setup MariaDB Dockerfile
    FROM debian:bookworm-slim
    RUN apt-get update && apt-get install -y \
        mariadb-server \
        && rm -rf /var/lib/apt/lists/*
    COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
    COPY tool/init.sh /init.sh

    RUN chmod +x /init.sh

    EXPOSE 3306

    CMD ["/init.sh"];

10. Create MariaDB Config File
    [mysqld]
    user            = mysql
    port            = 3306
    bind-address    = 0.0.0.0
    datadir         = /var/lib/mysql

11. Create MariaDB init.sh
    #!/bin/bash
    set -e

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld --user=mysql --bootstrap << SQL
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
    SQL

    exec mysqld --user=mysql

