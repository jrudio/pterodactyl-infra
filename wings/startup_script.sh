#! /bin/bash

# This script sets up the VM as a Wings server:
#   https://pterodactyl.io/wings/1.0/installing.html
#
# target linux distro: Ubuntu 22.04 LTS

install_dependencies() {
  sudo apt update

  # check if 'nano' and 'certbot' are not in path
  if [ -z "$(command -v nano)" ] || [ -z "$(command -v certbot)" ]; then
    echo "installing nano and certbot..."

    sudo apt install -y nano certbot
  fi

  # check if 'docker' is not in path
  if [ -z "$(command -v docker)" ]; then
    echo "docker not found. installing..."
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    echo "docker installed."
  fi


  # check if docker is no enabled and not running
  if [ "$(systemctl is-enabled --quiet docker)" != "enabled" ]; then
    echo "docker not enabled. enabling..."
    systemctl enable --now docker
    echo "docker enabled."
  fi

  if [ "$(systemctl is-active --quiet docker)" != "active" ]; then
    echo "docker not running. starting..."
    systemctl start docker
    echo "docker started."
  fi

}

install_wings() {
  # check if pterodactyl path already exists
  if [ ! -d "/etc/pterodactyl" ]; then
    echo "Pterodactyl wing config path doesn't exist. creating..."
    mkdir -p /etc/pterodactyl
  fi

  # check if wings already exist as global command
  if [ ! -z "$(command -v wings)" ]; then
    echo "wings already installed."
    return
  else
    echo "wings not installed yet."
  fi

  echo "installing Pterodactyl wings..."
  curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
  chmod u+x /usr/local/bin/wings
  echo "wings installed."
}

daemonize() {
  # check if wings.service exists in path, if it does then do not overwrite it
  if [ -f /etc/systemd/system/wings.service ]; then
    echo "wings.service already exists in path."
    return
  fi

  echo "daemonizing wings..."
  echo "
    [Unit]
    Description=Pterodactyl Wings Daemon
    After=docker.service
    Requires=docker.service
    PartOf=docker.service

    [Service]
    User=root
    WorkingDirectory=/etc/pterodactyl
    LimitNOFILE=4096
    PIDFile=/var/run/wings/daemon.pid
    ExecStart=/usr/local/bin/wings
    Restart=on-failure
    StartLimitInterval=180
    StartLimitBurst=30
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
  " > /etc/systemd/system/wings.service

  if [ ! -f /etc/systemd/system/wings.service ]; then
    echo "failed to save wings.service: /etc/systemd/system/wings.service not found"
    return
  fi

  systemctl enable --now wings

  echo "wings daemonized."
}

##################
# start script
##################


install_dependencies
install_wings
daemonize

echo "finished installing wings"

##################
# end script
##################