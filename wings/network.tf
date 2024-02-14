locals {
  detected_regions   = distinct([for server in var.game_servers : server.region])
  router_name_prefix = "${var.subnet_name_prefix}-router"
}

resource "google_compute_network" "wing_network" {
  name = var.network_name

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "wing_subnet" {
  for_each      = { for i, region in local.detected_regions : i => region }
  name          = "${var.subnet_name_prefix}-${each.value}"
  ip_cidr_range = "10.0.${each.key}.0/24"
  region        = each.value
  network       = google_compute_network.wing_network.id
}

resource "google_compute_subnetwork" "dummy_subnet" {
  name          = "${var.subnet_name_prefix}-dummy"
  ip_cidr_range = "10.254.0.0/24"
  region        = "us-west1"
  network       = google_compute_network.wing_network.id
}

# resource "google_compute_router" "wing_network_router" {
#   for_each = { for subnet_name in google_compute_subnetwork.wing_subnet : subnet_name.name => subnet_name }
#   name     = "${local.router_name_prefix}-${each.value.name}"
#   region   = each.value.region
#   network  = google_compute_network.wing_network.id

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

# resource "google_compute_firewall" "rust_game" {
#   name        = var.firewall_rules["rust_game"]
#   network     = google_compute_network.wing_network.name
#   description = "Allows connections to the game server ports"

#   allow {
#     protocol = "udp"
#     ports    = ["28015"]
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["28016", "28017", "28082"]
#   }

#   direction = "INGRESS"

#   source_ranges = ["0.0.0.0/0"]

#   target_tags = ["pterodactyl-wing"]
# }
