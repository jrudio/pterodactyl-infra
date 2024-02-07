#! /bin/bash

# This script sets up the VM as a Wings server:
#   https://pterodactyl.io/wings/1.0/installing.html
#
# target linux distro: Ubuntu 20.10

install_dependencies() {
  sudo apt update
  sudo apt install nano certbot

  curl -sSL https://get.docker.com/ | CHANNEL=stable bash

  systemctl enable --now docker
}

install_wings() {
  mkdir -p /etc/pterodactyl
  curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
  chmod u+x /usr/local/bin/wings
}

daemonize() {
  echo $WINGS_SERVICE > /etc/systemd/system/wings.service

  systemctl enable --now wings
}

##################
# start script
##################


install_dependencies
install_wings

echo "finished installing wings"

##################
# end script
##################