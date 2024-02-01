# Pterodactyl on GCP

## Required APIs

Service Directory API

## Provisioning

Ensure variable 'load_balancer_domain' is set to the domain you wish to access Pterodactyl with

Also, ensure that domain resolves to the IP address of the load balancer

## Add first admin user

Run `./create_user.sh` and follow the prompts to create an admin user

# Notes

https://github.com/pterodactyl/panel/blob/develop/docker-compose.example.yml


Debug database:

> docker pull mysql
> docker run -it --rm mysql mysql -h10.0.1.2 -uroot -p

Insert user:

docker exec <container-id> php artisan p:user:make
