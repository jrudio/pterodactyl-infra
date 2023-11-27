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

resource "google_compute_subnetwork" "connector_subnet" {
  name          = var.panel_connector_subnet
  ip_cidr_range = var.connector_subnet_range
  region        = var.region
  network       = google_compute_network.panel_network.id
}

resource "google_vpc_access_connector" "connector" {
  name = var.serverless_connector.name

  subnet {
    name = google_compute_subnetwork.connector_subnet.name
  }

  machine_type = var.serverless_connector.machine_type != "" ? var.serverless_connector.machine_type : "f1-micro"

  min_instances = 2
  max_instances = 3
}