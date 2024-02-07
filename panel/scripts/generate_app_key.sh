#! /bin/bash

# This script is used to extract the pterodactyl app key and save to a google cloud storage bucket
CONTAINER_IMAGE=ghcr.io/pterodactyl/panel

BUCKET_NAME=$(grep bucket_name ../terraform.tfvars | cut -d'=' -f2 | cut -d'"' -f2)

if [ -z "$BUCKET_NAME" ]; then
  echo "couldn't find bucket_name in the ../terraform.tfvars file. Exiting."
  exit 1
fi

BUCKET_NAME="$BUCKET_NAME-panel"

SERVICE_NAME=$(grep service_name ../terraform.tfvars | cut -d'=' -f2 | cut -d'"' -f2)

if [[ -z "$SERVICE_NAME" ]]; then
  echo "couldn't find service_name in the ../terraform.tfvars file. setting default value of 'pterodactyl'"

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

echo "generating new APP_KEY via $instance_name in $instance_zone..."

  # DOCKER_CONTAINER_ID=$(gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$LIST_DOCKER_CONTAINERS_COMMAND")
GENERATE_APP_KEY_COMMAND="
  DOCKER_CONTAINER_ID=\$(docker ps --filter ancestor=$CONTAINER_IMAGE -q)

  if [ -z \"\$DOCKER_CONTAINER_ID\" ]; then
    echo \"couldn't find a container with the '$CONTAINER_IMAGE' image. confirm the instance is running and docker is running\"
    exit 1
  fi

  echo \"running command on the '\$DOCKER_CONTAINER_ID' container...\"

  docker exec \$DOCKER_CONTAINER_ID php artisan key:generate --force -n

  echo \"generated new APP_KEY. save this to your terraform.tfvars file under 'panel.app_key' and re-run 'terraform plan && terraform apply'\"

  docker exec \$DOCKER_CONTAINER_ID cat .env
"

gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$GENERATE_APP_KEY_COMMAND"

# FETCH_APP_KEY_COMMAND="
#   DOCKER_CONTAINER_ID=\$(docker ps --filter ancestor=$CONTAINER_IMAGE -q)

#   # if [ -z \"\$DOCKER_CONTAINER_ID\" ]; then
#   #   echo \"couldn't find a container with the '$CONTAINER_IMAGE' image. confirm the instance is running and docker is running\"
#   #   exit 1
#   # fi

#   # echo \"running command on the '\$DOCKER_CONTAINER_ID' container...\"

#   docker exec \$DOCKER_CONTAINER_ID cat .env
# "
# APP_KEY=$(gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$FETCH_APP_KEY_COMMAND")

# echo $APP_KEY > .env && echo "saved APP_KEY to .env"
# # gcloud compute scp $instance_name:/tmp/.env $PWD --zone $instance_zone --verbosity error --tunnel-through-iap &&
# #   echo "saving new APP_KEY to gs://$BUCKET_NAME..." &&
# gsutil cp .env gs://$BUCKET_NAME &&
# rm .env

# # sign the gcs url
# # gsutil signurl -d 1h gs://$BUCKET_NAME/.env


echo "finished."