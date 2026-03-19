*This project has been created as part of the 42 curriculum by dvavryn.*

# Inception

## Description

Inception is a system administration project. The goal is to set up a small but complete web infrastructure using Docker Compose, running entirely inside a virtual machine.

The stack consists of three services, each in its own container:

- **NGINX** — the sole entry point, serving HTTPS on 443 with TLSv1.2/TLSv1.3 and a self-signed certificate
- **WordPress + PHP-FPM** — the application layer, communicating with NGINX over FastCGI on port 9000
- **MariaDB** — the database backend, accessed by WordPress over port 3306

Two named Docker volumes persist data across restarts:
- `wordpress` — stores WordPress files
- `mariadb` — stores the database

All containers are connected via a custom bridge network (`inception`) and restart automatically on failure. Credentials are managed via Docker secrets, not hardcoded in environment files or Dockerfiles.

## Intstructions

### Prerequisites

- Docker and Docker Compose installed
- Running inside a VM
- Add `dvavryn.42.fr` to `/etc/hosts` pointing to `127.0.0.1`

### Setup

1. Clone the repository:
	```bash
	git clone https://github.com/dvavryn/inception.git
	cd inception
	```

2. Populate the secret files:
	```
	secrets/db_root_password.txt
		# MariaDB root password
	secrets/db_user_password.txt
		# MariaDB WordPress user password	
	secrets/credentials.txt
		# Format key value
		#   wp_admin_user admin
		#   wp_admin_password adminpw
		#   wp_admin_email admin@mail.com
		#   wp_user_user user
		#   wp_user_password userpw
		#   wp_user_email user@mail.com
		#   hostname hostname.com
	```

3. Build and start everything:
	```bash
	make
	```
	This creates the host data directories at `/home/dvavryn/data/{wordpress,mariadb}` and starts all containers.

4. Open your browser and navigate to `https://dvavryn.42.fr`

### Makefile targets

|Target|Description|
|--|--|
|`all`|Setup directories, build and start containers|
|`up`|Start containers without rebuilding|
|`build`|Rebuild all images without cache|
|`down`|Stop and remove containers|
|`clean`|Full cleanup: containers, images, volumes, data|
|`fclean`|Same as clean, also removes Docker networks
|`re`|`fclean` + `all`|
|`logs`|Follow Docker Compose logs|

## Project Description

### Docker in this project

Each service has its own `Dockerfile` uner `srcs/requirements/<service>/`. Images are built from **Debian bookworm** (penultimate stable version). No pre-built application images are used — only the base OS image is pulled from Docker Hub.

The `docker-compose.yml` ties everything together: volumes, networks, build contexts, secrets and environment variables. The `Makefile` calls `docker compose` and handles host-side setup.

Key design choices:
- PHP-FPM runs in the WordPress container, NGINX is seperate — this follows the FastCGI seperation pattern
- NGINX is the only container with a published port (443)
- MariaDB and WordPress are not reachable from outside the Docker network
- The WordPress container waits for MariaDB to be healthy before initializing

### Virtual Machines vs Docker

| | Virutal Machine | Docker |
|---|---|---|
|**Isolation**|Full OS-level isolation via hypervisor | Process-level isolation via kernel namespaces|
|**Weight|Heavy - full OS per VM (gigabytes)|Lightweight - shares host kernel (MBs)|
|**Boot time**|Minutes|Seconds|
|**Use case**|Strong isolation, different OS kernels|Reproducible app environments, microservices|

This project requires a VM as the outer layer, with Docker containers running inside it. The VM provides the isolation boundary; Docker provides reproducible, declarative service packaging within it.

### Secrets vs Environment Variables

Environment variables are conveniant but risky for sensitive data: they can leak via `docker inspect`, process listings, or child processes. Docker secrets mount files into containers at `/run/secrets/name`, accessible only to the processes that need them and never exposed in image layers or compose config.

In this project:
- Non-sensitive config (`MYSQL_DATABASE`, `MYSQL_USER`, domain name) lives in `srcs/.env`
- Passwords and credentials aare passed as Docker secrets referenced in `docker-compose.yml`
- Dockerfiles contain no passwords whatsoever

### Docker Network vs Host Network

| |Docker Network (bridge)|Host Network|
|---|---|---|
|**Isolation**|Containers get their own network namespace|Container shares the host's network stack|
|**Security**|Services only reachable within the network by name|All container ports exposed on host directly|
|**Port control**|Explicit `ports:` mapping required to expose|No mapping needed, but no isolation either|

This project uses a custom bridge network named `inception`. Containers communicate by service name (e.g., WordPress connects to `mariadb:3306`). Only NGINX exposes a port to the host.

### Docker Volumes vs Bind Mounts

| |Named Volumes|Bind Mounts|
|---|---|---|
|**Management**|Managed by Docker, stored in Docker's data directory|Direct mapping to a host path|
|**Portability**|More portable, Docker handles the path|Tied to specific host directory structure|
|**Permissions**|Docker handles initialization|Host filesystem permissions apply|

This project uses two named volumes (`wordpress` and `mariadb`) configured in `docker-compose.yml` with a custom driver option pointing their data to `/home/dvavryn/data` on the host. This satisfies both the "named volumes" requirement and the "data in `/home/login/data`" requirement.

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best_practices/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WP-CLI documentation](https://wp-cli.org/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [PID 1 in containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)

### AI usage

- **Reference and explanation** — clarifying Docker concepts, TLS configuration option and MariaDB initialization patterns