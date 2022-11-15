#!/bin/bash

# setup submodules
git submodule init
git submodule update
git submodule update --recursive --remote

# upgrade system
sudo apt-get update
sudo apt-get full-upgrade

# install new packages
sudo apt-get install zsh ufw vim jq

# setup home config
pushd ./linux-home-config
source linux_setup.sh
linux_setup setup base
popd

# setup docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker "$USER"
sudo systemctl enable docker

# setup docker-compose
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p "$DOCKER_CONFIG/cli-plugins"
LATEST_COMPOSE_RELEASE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
echo "Latest docker compose: $LATEST_COMPOSE_RELEASE"
curl -SL "https://github.com/docker/compose/releases/download/$LATEST_COMPOSE_RELEASE/docker-compose-linux-armv6" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

# setup firewall
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow from 192.168.0.0/24 to any port 22
sudo ufw allow from 192.168.0.0/24 to any port 80
sudo ufw enable
