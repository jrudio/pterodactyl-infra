#! /bin/bash

# exit on error
set -e

DB_INSTANCE_NAME=$1
DB_ZONE=$2

REDIS_CONFIG_PATH=/etc/redis
MYSQL_CONFIG_PATH=/etc/mysql

DATA_DISK_NAME=pterodactyl-data
DATA_DISK_MOUNT_PATH=/mnt/disks/$DATA_DISK_NAME
REDIS_PATH=$DATA_DISK_MOUNT_PATH/redis
MYSQL_PATH=$DATA_DISK_MOUNT_PATH/mysql

if [ -z "$DB_INSTANCE_NAME" ]; then
  echo "please provide an instance name and zone"
  exit
fi

if [ -z "$DB_ZONE" ]; then
  echo "please provide a zone for the instance"
  exit
fi

echo "deploying config files..."

cd ./db-deps

CONFIG_SCRIPT=$(cat << EOF
  # sudo systemctl stop mysql
  # sudo systemctl stop redis

  sudo mv my.cnf $MYSQL_CONFIG_PATH
  sudo mv redis.conf $REDIS_CONFIG_PATH

  # sudo rsync -av /var/lib/mysql/ $MYSQL_PATH
  # sudo mv /var/lib/mysql /var/lib/mysql.bak

  sudo chown -R mysql $MYSQL_CONFIG_PATH
  sudo chown -R redis $REDIS_CONFIG_PATH

  sudo systemctl restart mysql
  # sudo systemctl start redis
  # sudo systemctl enable --now redis-server
EOF
)

# upload config files to home directory, then use sudo to move config files into privileged paths
gcloud compute scp my.cnf $DB_INSTANCE_NAME:~ --tunnel-through-iap --zone $DB_ZONE
gcloud compute scp redis.conf $DB_INSTANCE_NAME:~ --tunnel-through-iap --zone $DB_ZONE
gcloud compute ssh --tunnel-through-iap --zone $DB_ZONE $DB_INSTANCE_NAME -- "$CONFIG_SCRIPT"

# echo "deployed"
# echo "restarting redis and mysql..."

echo "finished deploying configs to $DB_INSTANCE_NAME"

# echo "initializing database..."
# gcloud compute scp init.sql $DB_INSTANCE_NAME:~ --tunnel-through-iap --zone $DB_ZONE
# gcloud compute ssh $DB_INSTANCE_NAME --tunnel-through-iap --zone $DB_ZONE -- "sudo mysql -u root < ./init.sql"
