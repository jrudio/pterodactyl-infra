resource "google_compute_network" "panel_network" {
  name = var.panel_network

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "panel_subnet" {
  name          = var.panel_subnet
  ip_cidr_range = var.panel_subnet_range
  region        = var.region
  network       = google_compute_network.panel_network.id
}
