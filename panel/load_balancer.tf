resource "google_compute_global_address" "panel_ip_address" {
  provider     = google-beta
  name         = "${local.panel_name}-address"
  description  = "Static IP for the panel database"
  address_type = "EXTERNAL"
  address      = var.panel.static_ip != "" ? var.panel.static_ip : null
  labels = {
    service = var.service_name
    env     = var.environment
  }
}

resource "google_compute_ssl_policy" "prod_ssl_policy" {
  name            = "production-ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_1"
}

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 9.0"
  project = data.google_project.default.project_id
  name    = var.service_name

  target_tags       = [local.panel_name, local.db_name]
  create_address    = false
  address           = google_compute_global_address.panel_ip_address.self_link
  firewall_networks = [google_compute_network.panel_network.self_link]
  https_redirect    = true
  ssl               = true
  managed_ssl_certificate_domains = [
    var.panel.url
  ]

  labels = {
    service = var.service_name
  }

  ssl_policy = google_compute_ssl_policy.prod_ssl_policy.self_link

  backends = {
    default = {
      port        = "80"
      protocol    = "HTTP"
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = "80"
      }

      log_config = {
        enable = false
      }

      groups = [
        {
          group = google_compute_instance_group_manager.panel.instance_group
        },
      ]
      iap_config = {
        enable = false
      }
    }
  }
}