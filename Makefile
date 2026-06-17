COMPOSE_FILE = src/docker-compose.yml
DATA_DIR = /home/$(USER)/data

.PHONY: all build up down clean fclean re

all: build up

# create the data folders for the db and wordpress
mkdata:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build: mkdata
	docker compose -f $(COMPOSE_FILE) build

up: mkdata
	docker compose -f $(COMPOSE_FILE) up -d

# stop the services
down:
	docker compose -f $(COMPOSE_FILE) down

# clean all the containers and images
clean:
	docker compose -f $(COMPOSE_FILE) down
	docker system prune -af

# fclean + volumes
fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

re: fclean all