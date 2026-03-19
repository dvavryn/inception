COMPOSE = srcs/docker-compose.yml

all: setup
	@docker compose -f $(COMPOSE) up -d --build

setup:
	@mkdir -p /home/dvavryn/data/wordpress
	@mkdir -p /home/dvavryn/data/mariadb

up:
	@docker compose -f $(COMPOSE) up -d

build:
	@docker compose -f $(COMPOSE) build --no-cache

down:
	@docker compose -f $(COMPOSE) down

stop:
	@docker compose -f $(COMPOSE) stop

start:
	@docker compose -f $(COMPOSE) start

clean: down
	@docker system prune -af
	@sudo rm -rf /home/dvavryn/data/wordpress/*
	@sudo rm -rf /home/dvavryn/data/mariadb/*

fclean: clean
	@docker volume prune -f
	@docker network prune -f

re: fclean all

delete: down
	@sudo rm -rf /home/dvavryn/data/wordpress/*
	@sudo rm -rf /home/dvavryn/data/mariadb/*

logs:
	@docker compose -f $(COMPOSE) logs -f

.PHONY: all setup down stop start clean fclean re logs
