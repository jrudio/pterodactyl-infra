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

resource "google_compute_router" "panel_network_router" {
  name    = var.router_name
  region  = google_compute_subnetwork.panel_subnet.region
  network = google_compute_network.panel_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.panel_network_router.name
  region                             = google_compute_router.panel_network_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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

# Dev stuff

resource "google_compute_subnetwork" "connector_subnet_dev" {
  name          = var.panel_connector_dev_subnet
  ip_cidr_range = var.connector_dev_subnet_range
  region        = var.region
  network       = google_compute_network.panel_network.id
}

resource "google_vpc_access_connector" "connector_dev" {
  name = var.serverless_connector_dev.name

  subnet {
    name = google_compute_subnetwork.connector_subnet_dev.name
  }

  machine_type = var.serverless_connector_dev.machine_type != "" ? var.serverless_connector_dev.machine_type : "f1-micro"

  min_instances = 2
  max_instances = 3
}
