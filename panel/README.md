# Pterodactyl on GCP

## After provisioning the infrastructure

1. Ensure the panel and db instances are healthy by sshing into each and checking each the docker process: docker ps && docker logs <container-id>

There is only one container per VM

2. Generate a new APP_KEY You can run the interactive generate_app_key.sh script

If you don't do this you won't be able to decrypt existing Pterodactyl data from the database on VM restarts or VM scale outs -- making Pterodactyl [unsusable]((https://pterodactyl.io/panel/1.0/getting_started.html#installation:~:text=Back%20up%20your%20encryption%20key%20(APP_KEY%20in%20the%20.env%20file).%20It%20is%20used%20as%20an%20encryption%20key%20for%20all%20data%20that%20needs%20to%20be%20stored%20securely%20(e.g.%20api%20keys).%20Store%20it%20somewhere%20safe%20%2D%20not%20just%20on%20your%20server.%20If%20you%20lose%20it%20all%20encrypted%20data%20is%20irrecoverable%20%2D%2D%20even%20if%20you%20have%20database%20backups.)).

3. Drop the auto-seeded 'panel' database from mysql ~~by running './delete_database.sh'~~

You can manually ssh into the <service-name>-db instance, `docker exec -it <mysql-container-id> mysql -h <db-internal-ip> -upterodactyl -p`, and then `DROP DATABASE panel;`.

Otherwise, Pterodactyl won't be able to create new entries (it will complain about duplicate server allocation) in the database after generating the new app key from step two.

4. Update your `terraform.tfvars` file with the new APP_KEY under `panel.app_key` and feel free to scale out your panel instances as needed by increasing the value of `panel.instance_count`

5. `terraform plan` + `terraform apply` to update the instance templates

6. Update your DNS settings for the domain to point to the newly provisioned IP address of the load balancer.

This will ensure that the Google-managed certificate can provision successfully

## Add first admin user

Run `./create_user.sh` and follow the prompts to create an admin user

# Random notes used for the above documentation

https://github.com/pterodactyl/panel/blob/develop/docker-compose.example.yml

## Debug database:

> docker pull mysql
> docker run -it --rm mysql mysql -h10.0.1.2 -uroot -p

sudo journalctl -u konlet-startup

Create the pterodactyl mysql user via [start up script as opposed to env vars](https://github.com/docker-library/mysql/issues/275#issuecomment-720366735)

## Insert Pterodactyl user:

docker exec <container-id> php artisan p:user:make

## Init script for the panel instances:

Due to ContainerOS being [locked down](https://stackoverflow.com/a/65116206), I couldn't download/install gcloud properly as there were sqlite errors (a dependency of gcloud)

Panel instances on start up will check the instance metadata for the value of 'app-key-url', download the app key via signed url, and then place the .env file into the mounted-to-docker directory for Pterodactyl to consume

## Viewing Pterodactyl logs

SSH into one of the panel instances

docker exec <container-id> cat /app/storage/logs/laravel-*