COMPOSE := srcs/docker-compose.yml
LOGIN	:= dom #change to dvavryn

all: setup
	@docker compose -f $(COMPOSE) up -d --build

setup:
	@mkdir -p ~/data/wordpress
	@mkdir -p ~/data/mariadb

down:
	@docker compose -f $(COMPOSE) down

stop:
	@docker compose -f $(COMPOSE) stop

start:
	@docker compose -f $(COMPOSE) start

clean: down
	@docker system prune -af
	@sudo rm -rf /home/$(login)/data/wordpress/*
	@sudo rm -rf /home/$(login)/data/mariadb/*	

fclean: clean
	@docker volume prune -f
	@docker network prune -f

re: fclean all

logs:
	@docker compose -f $(COMPOSE) logs -f

ps:
	@docker compose -f $(COMPOSE) ps

.PHONY: all setup down stop start clean fclean re logs ps