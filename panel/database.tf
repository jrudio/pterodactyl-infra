resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.panel_db_instance.name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_compute_global_address" "database_internal_ip_range" {
  name         = "${var.db_instance_name}-internal-address-${random_id.db_name_suffix.hex}"
  network      = google_compute_network.panel_network.id
  address_type = "INTERNAL"
  # address       = var.db_instance_ip
  prefix_length = 16
  purpose       = "VPC_PEERING"
}

resource "google_service_networking_connection" "panel_private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.panel_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.database_internal_ip_range.name]
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "panel_db_instance" {
  provider         = google-beta
  name             = "${var.db_instance_name}-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.panel_private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    insights_config {
      query_insights_enabled = true
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.panel_network.id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
  }

  deletion_protection = true
}

resource "google_sql_user" "users" {
  name     = var.database_user_email
  instance = google_sql_database_instance.panel_db_instance.name
  type     = "CLOUD_IAM_USER"
}