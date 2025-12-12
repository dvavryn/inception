Setup:

install bare debian trixie on vm

add user to sudo - nopasswd option

install basics like:
    make git curl gnupg lsb release vim vscode

prepare install docker:
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

install docker:
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

docker sudo rule:
    sudo usermod -aG docker $USER
    newgrp docker
    docker run hello-world
        // if it doesn't work something went wrong!

prepare project structure:
    mkdir -p srcs srcs/requirements/nginx/conf srcs/requirements/mariadb/conf srcs/requirements/wordpress/conf srcs/requirements/tools
    touch Makefile srcs/docker-compose.yml srcs/.env

edit host:
    sudo vim /etc/hosts
    change '127.0.0.1   localhost' to '127.0.0.1    localhost   dvavryn.42.fr'



setup project:
	1. nginx
		touch srcs/requirements/nginx/Dockerfile
