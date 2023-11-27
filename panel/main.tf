terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.1"
    }
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

data "local_file" "mysql_config" {
  filename = "${path.module}/db-deps/my.cnf"
}

data "local_file" "redis_config" {
  filename = "${path.module}/db-deps/redis.conf"
}

data "local_file" "startup_script" {
  filename = "${path.module}/db-deps/startup_script.sh"
}

data "google_compute_default_service_account" "default" {
}