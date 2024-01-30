## Pterodactl Infrastructure on Google Cloud

## Architecture

- Pterodactyl and it's components will be deployed on VMs

- The database will be deployed onto a VM as well with the option to use managed SQL database such as Cloud SQL

Depending on your business requirements you can scale the infrastructure

The below assumptions are made with Google Cloud in mind, will ponder difference services/scenarios when deploying to different cloud providers

Exploring this [container image](https://hub.docker.com/r/ccarney16/pterodactyl-panel/tags) to easily deploy the Pterodactyl panel ui

Database uses the [MySQL docker image](https://hub.docker.com/_/mysql)

The UI servers can be fronted by a Global HTTP Load Balancer, but hosted in a zone or single region

The UI servers will be managed by an instance group complete with health checks to ensure resiliency

## Wings

Easily deploys infrastructure for Wings (Game servers) onto Google Cloud*


 *Looking to support other cloud providers such as DigitalOcean