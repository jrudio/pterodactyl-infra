terraform {
  backend "gcs" {
    bucket = "pterodactyl-infra-tfstate" # change this to a globally unique bucket name
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tf_state" {
  name          = var.tf_bucket.name # change this to a globally unique bucket name
  force_destroy = false
  location      = var.tf_bucket.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  labels = {
    service = var.service_name
  }
}

data "google_project" "default" {
  project_id = var.project_id
}
