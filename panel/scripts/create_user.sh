#! /bin/bash

# This script is used to create a new user in the database by prompting the user for the information.


SERVICE_NAME=$(grep service_name ../terraform.tfvars | cut -d'=' -f2 | cut -d'"' -f2)

if [[ -z "$SERVICE_NAME" ]]; then
  echo "couldn't find service_name in the ../terraform.tfvars file of the current directory. setting default value of 'pterodactyl'"

  SERVICE_NAME="pterodactyl"
fi

SERVICE_NAME="$SERVICE_NAME-panel"

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

echo "creating db user on $instance_name in $instance_zone..."

LIST_DOCKER_CONTAINERS_COMMAND="docker ps --filter ancestor=ghcr.io/pterodactyl/panel -q"

DOCKER_CONTAINER_ID=$(gcloud compute ssh $instance_name --verbosity error --zone $instance_zone --tunnel-through-iap --command "$LIST_DOCKER_CONTAINERS_COMMAND")

# if container_id is empty, exit and tell user
if [ -z "$DOCKER_CONTAINER_ID" ]; then
  echo "couldn't find a container with the 'ghcr.io/pterodactyl/panel' image. confirm the instance is running and docker is running"
  exit 1
fi

echo "running create user command on the '$DOCKER_CONTAINER_ID' container..."

CREATE_USER_COMMAND="docker exec -i $DOCKER_CONTAINER_ID php artisan p:user:make"

gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$CREATE_USER_COMMAND"

echo "finished."