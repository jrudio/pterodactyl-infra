resource "google_compute_network" "panel_network" {
  name = "${var.service_name}-network"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "panel_subnet" {
  name          = "${var.service_name}-${var.region}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.panel_network.id
}
