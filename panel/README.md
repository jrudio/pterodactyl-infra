# Pterodactyl on GCP

## Cloud SQL for MySQL

Below information is a bit outdated as this now being migrated to a managed MySQL offering from Google

Database (MariaDB and Redis):

- Terraform code is written for Google Cloud
- Database instance is deployed without an external IP and you must connect to the instance over IAP if needed
- The panel will connect to the database via internal IP

## Deploy

- Make sure to set the variables within main.tfvars to your needs

### After provisioning

- Change the default Redis password in ./db-deps/redis.conf on line 1037
- Change the Redis data directory in ./db-deps/redis.conf on line 505 -- it defaults to '/mnt/disks/pterodactyl-data/redis'
- deploy_configs.sh uses gcloud to deploy configurations for Redis and MySQL, make sure to you are authorized to scp the files onto the deployed instance
- ./deploy_configs.sh


[1] https://pterodactyl.io/panel/1.0/getting_started.html#example-dependency-installation:~:text=Database%20Configuration

# Notes

- 'test' instance operates as a bastion host for testing the panel ui, the real panel will be deployed on Cloud Run