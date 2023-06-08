# this instance will host the pterodactyl UI and will be aiding the development
# of the Dockerfile and the pterodactyl-db instance
#
# Once we can successfully automate infra and docker container setup we won't need this instance
# resource "google_compute_instance" "test_instance" {
#   name         = "pterodactyl-ui-test"
#   machine_type = "e2-small"
#   zone         = var.zone

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-minimal-2210-amd64"

#       type = "pd-balanced"
#     }
#   }

#   network_interface {
#     subnetwork = google_compute_subnetwork.panel_subnet.name

#     access_config {

#     }
#   }

#   metadata_startup_script = data.local_file.test_instance_startup_script.content

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = data.google_compute_default_service_account.default.email
#     scopes = ["cloud-platform"]
#   }

#   tags = ["allow-iap", "pterodactyl-ui"]
# }

# data "local_file" "test_instance_startup_script" {
#   filename = "${path.module}/test_startup_script.sh"
# }

# resource "google_compute_firewall" "ui" {
#   name        = "allow-panel-ui"
#   network     = google_compute_network.panel_network.name
#   description = "Allows access to pterodactyl"

#   allow {
#     protocol = "tcp"
#     ports    = ["8080"]
#   }

#   direction = "INGRESS"

#   # allow internal network connectivity, wings server, and my ip
#   source_ranges = ["10.0.1.0/24", "34.82.238.19/32", "47.154.161.154/32"]

#   target_tags = ["pterodactyl-ui"]
# }