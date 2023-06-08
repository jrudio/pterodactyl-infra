provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "local_file" "startup_script" {
  filename = "${path.module}/startup_script.sh"
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_address" "game_server_ip" {
  name   = "${var.instance_prefix}-ip-address"
  region = var.region
}

# creates one instance
# TODO: create instances from a list
resource "google_compute_instance" "game_server" {
  name         = var.instance_prefix
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2210-amd64"

      type = "pd-balanced"

      size = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.wing_subnet.name

    access_config {
      nat_ip = google_compute_address.game_server_ip.address
    }
  }


  metadata_startup_script = data.local_file.startup_script.content

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  tags = ["pterodactyl-wing"]
}