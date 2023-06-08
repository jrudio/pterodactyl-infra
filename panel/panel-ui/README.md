## Prerequisite

Make sure you are authenticated properly with the gcloud command
Make sure "us-west1-docker.pkg.dev" is a pushable docker repository

## Build

copy .env.example into ./deps/
apply your settings

docker build -f wiper.Dockerfile -t <username>/pterodactyl:wiper-v0.0.1-ubuntu .

docker tag <username>/pterodactyl:wiper-v0.0.1-ubuntu us-west1-docker.pkg.dev/<project-id>/pterodactyl/ui:wiper-v0.0.1-ubuntu

docker push us-west1-docker.pkg.dev/<project-id>/pterodactyl/ui:wiper-v0.0.1-ubuntu

## Deploy

gcloud run deploy pterodactyl-ui --image us-west1-docker.pkg.dev/<project-id>/pterodactyl/ui:wiper-v0.0.1-ubuntu --allow-unauthenticated --port 8080 --region us-west1

## Deploy - development

<!-- gcloud run deploy pterodactyl-ui-dev --image us-west1-docker.pkg.dev/<project-id>/pterodactyl/ui:wiper-v0.0.1-ubuntu --allow-unauthenticated --port 8080 --region us-west1 --max-instances=2 -->
Use terraform to deploy the Cloud Run service and jobs