PTERODACTYL_DIR=/var/www/pterodactyl

if [[ -z "$PROJECT_ID" ]]; then
  echo "PROJECT_ID is required"
  exit
else
  gcloud config set project $PROJECT_ID
fi


if [[ ! -d "$PTERODACTYL_DIR" ]]; then
  echo "$PTERODACTYL_DIR does not exist..."
  exit
fi

cd $PTERODACTYL_DIR

checkENVContents() {
  if [[ -f "$PTERODACTYL_DIR/.env" ]]; then
    echo "printing .env..."
    cat $PTERODACTYL_DIR/.env
    echo "finished printing..."
  fi
}

downloadENVFile() {
  if [[ -z "$BUCKET_NAME" ]]; then
    echo "BUCKET_NAME is required"
    exit
  fi

  gsutil cp gs://$BUCKET_NAME/.env .
}

installDependencies() {
  echo "installing dependencies..."
  composer install --no-dev --optimize-autoloader
}

echo "user: $PTERODACTYL_USER"

PTERODACTYL_PASSWORD=$(gcloud secrets versions access latest --secret $PTERODACTYL_USER)


echo $PTERODACTYL_PASSWORD
exit

# checkENVContents
downloadENVFile
installDependencies
# checkENVContents


echo "running command: '$PTERODACTYL_CMD'"

if [[ $PTERODACTYL_CMD == "seed" ]]; then
  echo "seeding database...";
  php artisan migrate --seed --force
elif [[ $PTERODACTYL_CMD == "add_user" ]]; then
  echo "creating new user..."


# elif [[ $PTERODACTYL_CMD == "new_config" ]]; then
  # create a new .env file and dump it into a Cloud Storage bucket
  # echo "creating new .env file...";
  # php artisan p:environment:setup
  # php artisan p:environment:database
  # echo "creating new .env file..." > test.txt;
# elif [[ $PTERODACTYL_CMD == "new_key" ]]; then
  # only use this if first time setup for db
  # echo "generating new app key...";
else
  echo "unknown command";
  # echo "unknown command" > test.txt;
fi