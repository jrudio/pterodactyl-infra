## Purpose

To check connectivity to a private Cloud SQL instance from Cloud Run

## Deploy

gcloud run deploy cloud-sql-tester \
  --max-instances=1 \
  --cpu=1 \
  --memory=1024Mi \
  --labels=env=dev \
  --allow-unauthenticated \
  --execution-environment=gen1 \
  --vpc-connector=<vpc-serverless-connector-name> \
  --vpc-egress=all-traffic \
  --add-cloudsql-instances=<database-instance-name> \
  --no-cpu-boost \
  --description="test Cloud SQL connectivity over private IP" \
  --region="<region>"
  --set-secrets=DB_PASS=<database-password>,DB_USER=<database-username>,DB_PASS=<database-password>,DB_NAME=<database-name>,DB_PORT=<database-port>,INSTANCE_HOST=<database-host>


### Example

gcloud run deploy cloud-sql-tester \
  --max-instances=1 \
  --cpu=1 \
  --memory=1024Mi \
  --labels=env=dev \
  --allow-unauthenticated \
  --execution-environment=gen1 \
  --vpc-connector=pterodactyl-connector \
  --vpc-egress=all-traffic \
  --no-cpu-boost \
  --description="test Cloud SQL connectivity over private IP" \
  --region=us-west1 \
  --set-env-vars DB_USER=pterodactyl,DB_PASS=<password>,DB_NAME=panel,DB_PORT=3367,INSTANCE_HOST=<pterodactyl-instance-name>