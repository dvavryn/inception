# Developer Documentation

## Prerequisites

- Docker Engine (v20.10+) and Docker Compose plugin
- `sudo` access (required to create data directories under `/home/dvavryn/data/`)
- The domain `dvavryn.42.fr` must resolve to `127.0.0.1` in `/etc/hosts`:
```
127.0.0.1 dvavryn.42.fr
```

---

## Setting up from scratch

### 1. Clone the repository

```bash
git clone https://github.com/dvavryn/inception.git
cd inception
```

### 2. Create the secret files

The `secrets/` directory must exist with all three files. These are gitignored - you must create them manually.

**`secrets/db_root_password.txt`** - one line, the MariaDB root password:
```
your_root_password
```

**`secrets/db_user_password.txt`** - one line, the password for the `wordpress` database user:
```
yout_db_password
```

**`secrets/credentials.txt`**
```
wp_admin_user		admin
wp_admin_password	your_admin_password
wp_admin_email		admin@host.42.fr
wp_user_user		user
wp_user_password	your_user_password
wp_user_email		user@host.42.fr
hostname			host.42.fr
```

> The admin username must not contain "admin" or "administrator" required by the subject.

### 3. Review environment variables

`srcs/.env` holds non-sensitive configuration consumed by the containers:

```
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_USER_PASSWORD_FILE=/run/secrets/db_password
CREDENTIALS_FILE=/run/secrets/credentials
```

These are not secrets - they configure which database/user to create and tell the init scripts where to find the secret files at runtime.

---

## Building and launching the project

### Full build and start

```bash
make
```

This runs two steps:
1. `make setup` - creates `/home/dvavryn/data/wordpress` and `/home/dvavryn/data/mariadb` on the host
2. `docker compose up -d --build` - builds all images and starts containers in detached mode

### Rebuild from scratch (no cache)

```bash
make re
```

This runs `fclean` (stops containers, prunes all Docker objects, deletes host data) then rebuilds everything.

### Build images only (without starting)

```bash
make build
```

---

## Managing containers and volumes

### Common commands

```bash
# Start containers (already built)
make up

# Stop and remove containers (volumes preserved)
make down

# Stop without removing
make stop

# Restart stopped containers
make start

# Follow all logs
make logs

# Delete host data onlu (containers already down)
make delete
```

### Direct Docker Compose commands

The compose file lives at `srcs/docker-compose.yml`. You can use it directly:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p
docker compose -f srcs/docker-compose.yml reastart nginx
```

### Inspecting volumes

```bash
docker volume ls
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data
```

### Cleanup levels

|Command|What it removes|
|---|---|
|`make down`|Containers only|
|`make clean`|Container + all Docker images/cache + host data contents|
|`make fclean`|Everything above + Docker volumes and networks|
|`make re`|`fclean` then full rebuild|

---

## Project structure

```
inception/
├── secrets								# Gitignored - create manually
│   ├── credentials.txt
│   ├── db_root_password.txt
│   └── db_user_password.txt
├── srcs
│   ├── .env							# Non-sensitive environment config
│   ├── docker-compose.yml
│   └── requirements
│       ├── mariadb
│       │   ├── conf/50-server.cnf		# MariaDB server config
│       │   ├── tools/db-init.sh		# Database and user creation script
│       │   └── Dockerfile
│       ├── wordpress
│       │   ├── conf/www.conf			# PHP-FPM pool config
│       │   ├── tools/wp-init.sh		# WordPress install and config script
│       │   └── Dockerfile
│       └── nginx
│           ├── conf/nginx.conf			# NGINX site config
│           ├── tools/nginx-init.sh		# SSL cert generation script
│           └── Dockerfile
├── README.md
├── Makefile
├── DEV_DOC.md
└── USER_DOC.md
```

---

## Where data is stored and how it persists

### Named volumes

Two Docker named volumes are defined in `docker-compose.yml`:

|Volume|Mounted in container at|Host path|
|---|---|---|
|`mariadb_data`|`/var/lib/mysql`|`/home/dvavryn/data/mariadb`|
|`wordpress_Data`|`/var/html/www`|`/home/dvavryn/data/wordpress`|

Both volumes use the `local` driver with `type: none` and `o:bin`, which maps them to fixed host paths. This satisfied the subject's requirement for named volumes whose data lives under `/hom/login/data`.

### Persistence behaviour

- `make down` / `make stop` - data survives, volumes intact
- `make clean` / `make fclean` - host data directories are wipes (`rm -rf .../data/*`), volumes are removed; WordPress and the database must be re-initialized on next `make`
- Bin mounts are **not** used for the main volumes (forbidden by the subject); the `wordpress_data` volume is shared between the `wordpress` and `nginx` containers so NGINX can serve static assets directly

### Secrets at runtime

Docker mounts each secret as a read-onlu file inside the container:
```
/run/secrets/credentials
/run/secrets/db_password
/run/secrets/db_root_password
```

Init scripts (`db-init.sh`, `wp-init.sh`) read these files to configure the services. No passwords ever appear in environment variables, image layer, or `docker inspect output.