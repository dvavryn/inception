NAME = inception

all:
	@mkdir -p ~/data/db
	@mkdir -p ~/data/wordpress
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

re: down all

clean: down
	@docker system prune -af
	@sudo rm -rf ~/data

fclean: clean
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

.PHONY: all down re clean fclean