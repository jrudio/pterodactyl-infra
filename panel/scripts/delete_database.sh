#! /bin/bash

# This script is used to drop the 'panel' database


SERVICE_NAME=$(grep service_name ../terraform.tfvars | cut -d'=' -f2 | cut -d'"' -f2)

if [[ -z "$SERVICE_NAME" ]]; then
  echo "couldn't find service_name in the ../terraform.tfvars file of the current directory. setting default value of 'pterodactyl'"

  SERVICE_NAME="pterodactyl"
fi

SERVICE_NAME="$SERVICE_NAME-db"

echo "fetching instances that have the '$SERVICE_NAME' tag..."

instances=$(gcloud compute instances list --verbosity error --filter tags.items=$SERVICE_NAME --format 'table[no-heading](name,zone,INTERNAL_IP)')

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

IFS=' ' read -r instance_name instance_zone instance_ip <<< "$instances"

echo "deleting pterodactyl user using $instance_name in $instance_zone..."

DROP_DB_COMMAND="
  env
  echo \"creating a shell for you to run the DROP DATABASE command...\"

  docker run --rm -it mysql bash -c \"mysql -h$instance_ip -upterodactyl -p\"
"

gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$DROP_DB_COMMAND"

echo "finished."