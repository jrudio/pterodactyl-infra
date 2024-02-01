resource "google_compute_address" "panel_ip_address" {
  name = "${local.panel_name}-address"

  description = "Static IP for the panel database"
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

  target_tags       = [local.panel_name]
  address           = google_compute_address.panel_ip_address.address
  firewall_networks = [google_compute_network.panel_network.self_link]
  https_redirect    = true
  ssl               = true
  managed_ssl_certificate_domains = [
    var.load_balancer_domain
  ]

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
          # Each node pool instance group should be added to the backend.
          group = google_compute_instance_group_manager.panel.instance_group
        },
      ]
      iap_config = {
        enable = false
      }
    }
  }
}