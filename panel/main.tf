provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
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

# resource "google_compute_address" "database_internal_ip" {
#   name         = "${var.db_instance_name}-internal-address"
#   subnetwork   = google_compute_subnetwork.panel_subnet.id
#   address_type = "INTERNAL"
#   address      = var.db_instance_ip
#   region       = var.region
# }

# resource "google_compute_instance" "database" {
#   name         = var.db_instance_name
#   machine_type = var.machine_type
#   zone         = var.zone

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-minimal-2210-amd64"

#       type = "pd-balanced"
#     }
#   }

#   network_interface {
#     subnetwork = google_compute_subnetwork.panel_subnet.name
#     network_ip = google_compute_address.database_internal_ip.address
#   }

#   metadata_startup_script = data.local_file.startup_script.content

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = data.google_compute_default_service_account.default.email
#     scopes = ["cloud-platform"]
#   }

#   tags = ["allow-iap", "pterodactyl-db"]

#   lifecycle {
#     ignore_changes = [
#       attached_disk
#     ]
#   }
# }
