resource "google_compute_firewall" "wing_daemon" {
  name        = local.firewall_rules.wing
  network     = google_compute_network.wing_network.name
  description = "Allows wing daemon communication with Pterodactyl"

  allow {
    protocol = "tcp"
    ports    = ["8080", "2022"]
  }

  direction = "INGRESS"

  source_ranges = var.allowed_ip_addresses.wings

  target_tags = [local.wing_template_tag]
}

resource "google_compute_firewall" "ssh" {
  name        = local.firewall_rules.ssh
  network     = google_compute_network.wing_network.name
  description = "Allows ssh access"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = var.allowed_ip_addresses.ssh

  target_tags = [local.wing_template_tag]
}

resource "google_compute_firewall" "game_ports" {
  for_each    = { for i, server in var.game_servers : i => server.open_ports }
  name        = "wings-allow-${each.value.name}"
  network     = google_compute_network.wing_network.name
  description = "Allow access to game port"

  allow {
    protocol = "udp"
    ports    = ["8211"]
  }

  allow {
    protocol = ""
    ports = []
  }

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["wing-fw-${var.game_servers[each.key].instance_name}-${var.game_servers[i].zone}"]
}


locals {
  firewall_rules = {
    ssh  = "wings-allow-ssh"
    wing = "wings-allow-wing"
  }
}