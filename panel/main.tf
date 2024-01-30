# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "4.69.1"
#     }
#   }
# }

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
