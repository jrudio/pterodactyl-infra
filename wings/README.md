# Host a Rust Dedicated Server on the Cloud

## Supported Cloud

- Google Cloud

## Google Cloud

### Machine Type

For development purposes a machine type of e2-standard-2 (2 CPU, 8GB RAM) works well for potentially 50 people

For production you likely want a Performance or Extreme persistent disk as opposed to a standard disk for optimal server performance. Standard or Balanced are fine for development.

- https://cloud.google.com/compute/docs/disks/performance#disk_types

### Prerequisites

- [Create a Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

- Ensure you have Project Owner permissions

- Ensure you have [gcloud cli installed locally](https://cloud.google.com/sdk/docs/install-sdk)

- Login with gcloud cli: `gcloud auth login`

- Ensure you have [Terraform installed](https://developer.hashicorp.com/terraform/downloads)

### Deployment

1. From this directory (./cloud) run `terraform init`

2. `terraform plan`

3. `terraform apply`



## Wing certificate

Manually fetch certificates by setting hash in the DNS records

sudo certbot -d test-node-1.dev.justinrudio.com --manual --preferred-challenges dns certonly

https://pterodactyl.io/tutorials/creating_ssl_certificates.html#method-1:-certbot