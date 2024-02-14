# Provision a Pterodactyl Wing server

### Prerequisites

- [Create a Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

- Ensure you have Project Owner permissions

- Ensure you have [gcloud cli installed locally](https://cloud.google.com/sdk/docs/install-sdk)

- Login with gcloud cli: `gcloud auth login`

- Ensure you have [Terraform installed](https://developer.hashicorp.com/terraform/downloads)

### Deployment

1. Create `terraform.tfvars` and fill out the required variables listed in `vars.tf`

`terraform init`

2. `terraform plan`

3. `terraform apply`



## Wing certificate

To generate new certificates:

Manually fetch certificates by setting hash in the DNS records

sudo certbot -d test-node-1.dev.justinrudio.com --manual --preferred-challenges dns certonly

https://pterodactyl.io/tutorials/creating_ssl_certificates.html#method-1:-certbot

Save the generated certificates to the provisioned GCS bucket: gs://<project-id>-wing-certificates

Bucket is versioned and has the following directory structure:

gs:<project-id>-wing-certificates/<node-fqdn>/
  README    cert1.pem  chain1.pem     fullchain1.pem  privkey1.pem

Restoring certificates:

Download the 4 files from the bucket and place them in the following directory:

/etc/letsencrypt/archive/<node-fqdn>

then symlink the files to:

/etc/letsencrypt/live/<node-fqdn>