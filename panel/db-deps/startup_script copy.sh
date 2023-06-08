#! /bin/bash

# This script sets up the database portion (Redis, MySQL) of Pterodactyl[1] and the script itself is intended to be ran as root
# The database services will run as a non-root user
#
# As part of the setup, the script will temporarily download PHP and Composer according to the install documentation[2]
# to help configure and seed the database. As PHP and Composer is only initially required, it will be removed after seeding.
#
# target linux distro: Ubuntu 20.10
#
# [1] https://pterodactyl.io/
# [2] https://pterodactyl.io/panel/1.0/getting_started.html#example-dependency-installation

# non-root user to run the database as
NONROOT_USER=db-user
NONROOT_USER_PASSWORD=test123 # change the password once provisioned!
DISK_GROUP=data-disk-group
DATA_DISK=sdb
DATA_DISK_NAME=pterodactyl-data
DATA_DISK_MOUNT_PATH=/mnt/disks/$DATA_DISK_NAME
REDIS_PATH=$DATA_DISK_MOUNT_PATH/redis
MYSQL_PATH=$DATA_DISK_MOUNT_PATH/mysql

install_dependencies() {
  apt update

  apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg nano

  apt update

  curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

  apt -y install redis-server mariadb-server
}

format_disk() {
  echo "formatting disk..."
  echo "data disk should be \"sdb\""
  lsblk

  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DATA_DISK
}

mount_disk() {
  mkdir -p $DATA_DISK_MOUNT_PATH

  mount -o discard,defaults /dev/$DATA_DISK $DATA_DISK_MOUNT_PATH

  chmod a+rw $DATA_DISK_MOUNT_PATH
}

configure_automount() {
  cp /etc/fstab /etc/fstab.backup

  DATA_DISK_UUID=$(blkid /dev/$DATA_DISK)

  # VM boot will fail if disk is not available
  # add 'nofail' after "defaults" to continue booting even if data disk is not available
  echo "UUID=$DATA_DISK_UUID $DATA_DISK_MOUNT_PATH ext4 discard,defaults 0 2" >> /etc/fstab
}

add_data_directories() {
  if [ ! -d $REDIS_PATH ]; then
    mkdir $REDIS_PATH

    chown -R redis $REDIS_PATH

    echo "created redis data directory"
  fi

  if [ ! -d $MYSQL_PATH ]; then
    mkdir $MYSQL_PATH

    chown -R mysql $MYSQL_PATH

    echo "created mysql data directory"
  fi
}

# check if disk is mounted, otherwise format and mount (likely newly provisioned or first startup ever)
check_data_disk_and_mount() {
  echo "checking if data disk is mounted..."

  if [ ! -d $DATA_DISK_MOUNT_PATH ]; then
    echo "data disk is not mounted"
    echo "formatting disk and mounting..."

    format_disk
    mount_disk
    configure_automount
  else
    echo "disk is mounted"
  fi
}

set_permissions() {
  groupadd $DISK_GROUP
  usermod -a -G data-disk-group redis
  usermod -a -G data-disk-group mysql

  chgrp -R $DISK_GROUP $DATA_DISK_MOUNT_PATH
  chmod -R g+rw $DATA_DISK_MOUNT_PATH
}

##################
# start script
##################

check_data_disk_and_mount
add_data_directories
install_dependencies
set_permissions

##################
# end script
##################