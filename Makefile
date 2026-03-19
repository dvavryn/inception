COMPOSE = srcs/docker-compose.yml

all: setup
	@docker compose -f $(COMPOSE) up -d --build

setup:
	@mkdir -p /home/dvavryn/data/wp
	@mkdir -p /home/dvavryn/data/db

up:
	@docker compose -f $(COMPOSE) up -d

down:
	@docker compose -f $(COMPOSE) down

stop:
	@docker compose -f $(COMPOSE) stop

start:
	@docker compose -f $(COMPOSE) start

clean: down
	@docker system prune -af
	@sudo rm -rf /home/dvavryn/data/wp/*
	@sudo rm -rf /home/dvavryn/data/db/*

fclean: clean
	@docker volume prune -f
	@docker network prune -f

re: fclean all

delete: down
	@sudo rm -rf /home/dvavryn/data/wp/*
	@sudo rm -rf /home/dvavryn/data/db/*

logs:
	@docker compose -f $(COMPOSE) logs -f

.PHONY: all setup down stop start clean fclean re logs
