#! /bin/bash

# This script sets up the custom Docker image I built to run Pterodactyl's UI for development purposes
#
# target linux distro: Ubuntu 20.10
#
# [1] https://pterodactyl.io/


install_dependencies() {
  apt update

  apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg nano

  apt update

  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}


##################
# start script
##################

install_dependencies

##################
# end script
##################