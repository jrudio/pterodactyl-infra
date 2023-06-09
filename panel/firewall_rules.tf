resource "google_compute_firewall" "iap" {
  name        = var.firewall_rules["iap"]
  network     = google_compute_network.panel_network.name
  description = "Allows users to connect to an instance over IAP"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap"]
}

resource "google_compute_firewall" "redis" {
  name        = var.firewall_rules["redis"]
  network     = google_compute_network.panel_network.name
  description = "Allows applications to connect to the database's redis service"

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  direction = "INGRESS"

  source_ranges = ["10.0.1.0/24"]

  target_tags = ["pterodactyl-db"]
}

resource "google_compute_firewall" "mysql" {
  name        = var.firewall_rules["mysql"]
  network     = google_compute_network.panel_network.name
  description = "Allows applications to connect to the database's MySQL service"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  direction = "INGRESS"

  source_ranges = ["10.0.1.0/24"]

  target_tags = ["pterodactyl-db"]
}