#! /bin/bash

# This script is used to turn on/off recaptcha (in case it breaks)

DESIRED_STATE=$1

if [ "$DESIRED_STATE" != "on" ] && [ "$DESIRED_STATE" != "off" ]; then
  echo "error: invalid desired state. must be 'on' or 'off'"
  exit 1
fi

if [ "$DESIRED_STATE" != "on" ]; then
  DESIRED_STATE="false"
else
  DESIRED_STATE="true"
fi

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

# set this variable to a multi-line string
TOGGLE_RECAPTCHA_COMMAND="
  # docker run --rm -i mysql mysql -h$instance_ip -upterodactyl -p -D panel
  docker run --rm -i mysql mysql -h$instance_ip -upterodactyl -p -D panel -e 'UPDATE settings SET value=$DESIRED_STATE WHERE \`id\` = 2;'
  # docker run --rm -i mysql mysql -h$instance_ip -upterodactyl -p -D panel -e 'UPDATE settings SET value=$DESIRED_STATE WHERE \`key\` = \`settings::recaptcha:enabled\`;'
"
gcloud compute ssh $instance_name --zone $instance_zone --verbosity error --tunnel-through-iap --command "$TOGGLE_RECAPTCHA_COMMAND"

echo "finished."

# UPDATE settings SET value=false WHERE `key` = 'settings::recaptcha:enabled';