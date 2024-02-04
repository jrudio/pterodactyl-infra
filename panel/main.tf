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

resource "google_storage_bucket" "panel_data" {
  name          = "${var.panel.bucket_name_prefix}-panel" # change this to a globally unique bucket name
  force_destroy = false
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  labels = {
    service = var.service_name
  }
}

resource "google_storage_bucket_iam_binding" "panel_data" {
  bucket = google_storage_bucket.panel_data.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.panel.email}",
  ]
}

data "google_project" "default" {
  project_id = var.project_id
}
