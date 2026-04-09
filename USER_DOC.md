# User Documentation

## What services are provided

The stack runs three services:

|Service|Role|Access|
|---|---|---|
|**NGINX**|HTTPS reverse proxy|Port 443 - the only public entry point|
|**WordPress + PHP-FPM**|The website and its admin panel|Via NGINX (not directly exposed)|
|**MariaDB**|Database backend|Internal only (not accessible from outside)|

The WordPress site is available at `https://dvavryn.42.fr`.

---

## Starting and stoping the project

**Start (build if needed):**
```bash
make
```

**Stop (container down, data preserved):**
```bash
make down
```

**Stop without removing containers:**
```bash
make stop
```

**Start previously stopped containers:**
```bash
make start
```

All containers are configured with `restart: always`, so they come back up automatically after a crash or system reboot (as long as the Docker daemon is running).

---

## Accessing the website and administration panel

**Website:**
```
https://dvavryn.42.fr
```

**WordPress admin panel:**
```
https://dvavryn.42.fr/wp-admin
```

> The site uses a self-signed TLS certificate. Your browser will show a security warning - this is expected. Accept the exception to proceed.

---

## Locatinf and managing credentials

Credentials are stored in the `secrets/` dire3ctory at the root of the repository. These files are gitignored and never committed.

|File|Contains|
|---|---|
|`secrets/credentials.txt`|Wordpress admin and second user credentials, site hostname|
|`secrets/db_user_password.txt`|MariaDB password for the WordPress database user|
|`secrets/db_root_password.txt`|MariaDB root password|

**Format of `credentials.txt`:**
```
wp_admin_user		<username>
wp_admin_password	<password>
wp_admin_email		<email>
wp_user_user		<username>
wp_user_password	<password>
wp_user_email		<email>
hostname			<domain>
```

At runtime, these files are mounted into containers via Docker secrets at `/run/secrets/`.

---

## Checking that services are running correctly

**List running containers:**
```bash
docker compose -f srcs/docker-compose.yml ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should show status `Up`.

**Follow live logs:
```bash
make logs
```

**Check a specific service:**
```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

**Quick connectivity check:**
```bash
curl -k https://dvavryn.42.fr
```

A successful response returns WordPress HTML. A connection refused or certificate error indicates NGINX is not running.