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
  for_each = { for i, server in var.game_servers : i => server }
  name     = format("%s-%s-%s", var.network_name, each.value.instance_name, each.value.zone)

  network       = var.network_name
  description   = format("Firewall rules for '%s' Pterodactyl Wing", each.value.instance_name)
  direction     = "INGRESS"
  target_tags   = [format("%s-%s-%s", var.network_name, each.value.instance_name, each.value.zone)] # <network>-<instance-name>-<instance-zone>
  source_ranges = each.value.allowed_ip_list

  allow {
    protocol = "tcp"
    ports    = each.value.firewall_rules_tcp
  }
  allow {
    protocol = "udp"
    ports    = each.value.firewall_rules_udp
  }
}

locals {
  firewall_rules = {
    ssh  = "wings-allow-ssh"
    wing = "wings-allow-wing"
  }
}