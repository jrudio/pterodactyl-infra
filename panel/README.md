# Pterodactyl on GCP

## Required APIs

Service Directory API

# Notes

https://github.com/pterodactyl/panel/blob/develop/docker-compose.example.yml


Debug database:

> docker pull mysql
> docker run -it --rm mysql mysql -h10.0.1.2 -uroot -p

Insert user:

docker exec <container-id> php artisan p:user:make --username <username> --password <password> --admin --name-first <first-name> --name-last <last-name> --email <email-address>
