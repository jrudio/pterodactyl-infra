resource "google_compute_firewall" "iap" {
  name        = local.firewall_rules.iap
  network     = google_compute_network.panel_network.name
  description = "Allows users to connect to an instance over IAP"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = ["35.235.240.0/20"]
  target_tags   = [local.firewall_rules["iap"]]
}

resource "google_compute_firewall" "redis" {
  name        = local.firewall_rules.redis
  network     = google_compute_network.panel_network.name
  description = "Allows applications to connect to the database's redis service"

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  direction = "INGRESS"

  source_ranges = [local.panel_subnet_range]

  target_tags = [local.cache_name]
}

resource "google_compute_firewall" "mysql" {
  name        = local.firewall_rules.mysql
  network     = google_compute_network.panel_network.name
  description = "Allows applications to connect to the database's MySQL service"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  direction = "INGRESS"

  source_ranges = [local.panel_subnet_range]

  target_tags = [local.db_name]
}

resource "google_compute_firewall" "health_check_probers" {
  name        = "${var.service_name}-health-check"
  network     = google_compute_network.panel_network.name
  description = "Allows Google's health check probers to talk to instances on all ports"

  allow {
    protocol = "tcp"
    # ports    = ["1-65535"]
    ports = ["3306"]
  }

  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

locals {
  firewall_rules = tomap({
    iap   = "${var.service_name}-allow-iap"
    redis = "${var.service_name}-allow-redis"
    mysql = "${var.service_name}-allow-mysql"
  })
}