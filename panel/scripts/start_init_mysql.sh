#! /bin/bash

# This script is used to create a new user in the database by prompting the user for the information.
INIT_SCRIPT_FILENAME=init_mysql_user.sh
INIT_MYSQL_SCRIPT_PATH=/tmp

SERVICE_NAME=$(grep service_name terraform.tfvars | cut -d'=' -f2 | cut -d'"' -f2)

if [[ -z "$SERVICE_NAME" ]]; then
  echo "couldn't find service_name in the terraform.tfvars file of the current directory. setting default value of 'pterodactyl'"

  SERVICE_NAME="pterodactyl"
fi

SERVICE_NAME="$SERVICE_NAME-db"

echo "fetching instances that have the '$SERVICE_NAME' tag..."

instances=$(gcloud compute instances list --verbosity error --filter tags.items=$SERVICE_NAME --format 'table[no-heading](name,zone)')

IFS=$'\n' read -rd '' -a instances <<< "$instances"

echo "select which instance to connect to:"

i=0

for instance in "${instances[@]}"; do
  # print the array
  echo "$instance [$i]"
  ((i++))
done

# read the instance index from stdin
read -p "instance index: " instance_index

# check if instance_index is not a number
if ! [[ $instance_index =~ ^[0-9]+$ ]]; then
  echo "instance index must be a number"
  exit 1
fi

IFS=' ' read -r instance_name instance_zone <<< "$instances"

echo "initializing the mysql db user on $instance_name in $instance_zone..."

LIST_DOCKER_CONTAINERS_COMMAND="docker ps --filter ancestor=mysql -q"

DOCKER_CONTAINER_ID=$(gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$LIST_DOCKER_CONTAINERS_COMMAND")

# if container_id is empty, exit and tell user
if [ -z "$DOCKER_CONTAINER_ID" ]; then
  echo "couldn't find a container with the 'mysql' image. confirm the instance is running and docker is running"
  exit 1
fi

echo "running create user command on the '$DOCKER_CONTAINER_ID' container..."

# set this variable to a multi-line string
CREATE_MYSQL_USER_COMMAND="
  sudo chmod +x $INIT_MYSQL_SCRIPT_PATH/$INIT_SCRIPT_FILENAME &&
  docker cp '$INIT_MYSQL_SCRIPT_PATH/$INIT_SCRIPT_FILENAME' $DOCKER_CONTAINER_ID:/ &&
  docker exec -i $DOCKER_CONTAINER_ID bash -c 'sh ./$INIT_SCRIPT_FILENAME'
  # docker exec -i $DOCKER_CONTAINER_ID bash -c 'sh ./test.sh'
"


gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$CREATE_MYSQL_USER_COMMAND"

echo "finished."