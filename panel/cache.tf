resource "google_service_account" "cache" {
  account_id   = local.cache_name
  display_name = "${title(join(" ", split("-", var.service_name)))} Cache"
}

resource "google_compute_address" "cache" {
  name         = local.cache_name
  description  = "Static internal IP address used for the cache"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.panel_subnet.id
}

resource "google_compute_instance_group_manager" "cache" {
  provider = google-beta
  name     = "${local.cache_name}-igm"

  base_instance_name = local.cache_name
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.cache.self_link_unique
  }

  target_size = 1
}

resource "google_compute_instance_template" "cache" {
  name        = "${local.cache_name}-template"
  description = "Template for the Redis instance that caches Pterodactyl panel data"

  tags = [local.firewall_rules.iap, local.cache_name]

  labels = {
    environment = var.environment
    service     = var.service_name
  }

  instance_description = "Database caching server for Pterodactyl"
  machine_type         = var.cache_machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = data.google_compute_image.cos.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.panel_subnet.id
    network_ip = google_compute_address.cache.address
  }

  metadata = {
    "gce-container-declaration" = module.gce-container-cache.metadata_value
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cache.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = false
  }
}

module "gce-container-cache" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.1"

  container = {
    image = var.cache_container_image
  }

  restart_policy = "Always"
}

# resource "google_compute_health_check" "autohealing" {
#   name                = "autohealing-health-check"
#   check_interval_sec  = 5
#   timeout_sec         = 5
#   healthy_threshold   = 2
#   unhealthy_threshold = 10 # 50 seconds

#   http_health_check {
#     request_path = "/healthz"
#     port         = "8080"
#   }
# }

locals {
  cache_name = "${var.service_name}-cache"
}