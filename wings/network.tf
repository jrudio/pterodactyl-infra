resource "google_compute_network" "wing_network" {
  name = var.wing_network

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "wing_subnet" {
  name          = var.wing_subnet
  ip_cidr_range = var.subnet_range
  region        = var.region
  network       = google_compute_network.wing_network.id
}

# resource "google_compute_router" "wing_network_router" {
#   name    = var.router_name
#   region  = google_compute_subnetwork.wing_subnet.region
#   network = google_compute_network.wing_network.id

#   bgp {
#     asn = 64514
#   }
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = var.nat_name
#   router                             = google_compute_router.wing_network_router.name
#   region                             = google_compute_router.wing_network_router.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }

resource "google_compute_firewall" "rust_game" {
  name        = var.firewall_rules["rust_game"]
  network     = google_compute_network.wing_network.name
  description = "Allows connections to the game server ports"

  allow {
    protocol = "udp"
    ports    = ["28015"]
  }

  allow {
    protocol = "tcp"
    ports    = ["28016", "28017", "28082"]
  }

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["pterodactyl-wing"]
}

resource "google_compute_firewall" "wing_daemon" {
  name        = var.firewall_rules["wing"]
  network     = google_compute_network.wing_network.name
  description = "Allows wing daemon communication with Pterodactyl"

  allow {
    protocol = "tcp"
    ports    = ["8080", "2022"]
  }

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["pterodactyl-wing"]
}

resource "google_compute_firewall" "ssh" {
  name        = var.firewall_rules["ssh"]
  network     = google_compute_network.wing_network.name
  description = "Allows ssh access"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = ["${var.allowed_ssh_ip}/32"]

  target_tags = ["pterodactyl-wing"]
}