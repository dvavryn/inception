all: 
	cd srcs && docker compose up -d --build

build: 
	cd srcs && docker compose build

up: 
	cd srcs && docker compose up -d

fg:
	cd srcs && docker compose up

down:
	cd srcs && docker compose down

clean: 
	cd srcs && docker system prune

fclean: 
	cd srcs && docker system prune -a