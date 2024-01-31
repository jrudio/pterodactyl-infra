resource "google_compute_network" "panel_network" {
  name = "${var.service_name}-network"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "panel_subnet" {
  name          = "${var.service_name}-${var.region}"
  ip_cidr_range = local.panel_subnet_range
  region        = var.region
  network       = google_compute_network.panel_network.id
}

resource "google_compute_router" "panel" {
  name    = "${var.service_name}-router"
  region  = google_compute_subnetwork.panel_subnet.region
  network = google_compute_network.panel_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "panel" {
  name                               = "${var.service_name}-nat"
  router                             = google_compute_router.panel.name
  region                             = google_compute_router.panel.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

locals {
  panel_subnet_range = "10.0.1.0/24"
}