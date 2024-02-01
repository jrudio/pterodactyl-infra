resource "google_service_account" "panel" {
  account_id   = "${var.service_name}-panel"
  display_name = "${title(join(" ", split("-", var.service_name)))} Panel"
}

resource "google_compute_instance_group_manager" "panel" {
  provider = google-beta
  name     = "${var.service_name}-igm"

  base_instance_name = local.panel_name
  zone               = var.zone

  named_port {
    name = "http"
    port = "80"
  }

  version {
    instance_template = google_compute_instance_template.panel.self_link_unique
  }

  target_size = 1
}

resource "google_compute_instance_template" "panel" {
  name        = "${local.panel_name}-template"
  description = "Template for the Pterodactyl panel"

  tags = [local.firewall_rules.iap, local.panel_name]

  labels = {
    environment = var.environment
    service     = var.service_name
  }

  instance_description = "Front-end app server for Pterodactyl"
  machine_type         = var.panel_machine_type
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
    // backup the disk every day
    # resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  // Use an existing disk resource
  # disk {
  #   // Instance Templates reference disks by name, not self link
  #   source      = google_compute_disk.foobar.name
  #   auto_delete = false
  #   boot        = false
  # }

  network_interface {
    subnetwork = google_compute_subnetwork.panel_subnet.id
  }

  metadata = {
    "gce-container-declaration" = module.gce-container-panel.metadata_value
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.panel.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = false
  }
}

data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

module "gce-container-panel" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.1"

  container = {
    image = var.panel_container_image
    volumeMounts = [
      {
        mountPath = "/app/var/"
        name      = "host-path"
        readOnly  = false
      }
    ]
    env = [
      {
        name  = "APP_ENV"
        value = "prod"
      },
      {
        name  = "APP_DEBUG"
        value = false
      },
      {
        name  = "APP_ENVIRONMENT_ONLY"
        value = false
      },
      {
        name  = "APP_URL"
        value = var.panel.url
      },
      {
        name  = "APP_TIMEZONE"
        value = var.panel.timezone
      },
      {
        name  = "APP_SERVICE_AUTHOR"
        value = var.panel.service_author
      },
      {
        name  = "DB_HOST"
        value = google_compute_address.db.address
      },
      {
        name  = "DB_PORT"
        value = "3306"
      },
      {
        name  = "DB_PASSWORD"
        value = "abc123"
      },
      {
        name  = "DB_DATABASE"
        value = "panel"
      },
      {
        name  = "CACHE_DRIVER"
        value = "redis"
      },
      {
        name  = "SESSION_DRIVER"
        value = "redis"
      },
      {
        name  = "QUEUE_DRIVER"
        value = "redis"
      },
      {
        name  = "REDIS_HOST"
        value = google_compute_address.cache.address
      }
    ]
  }

  volumes = [
    {
      name = "host-path"

      hostPath = {
        path = "/home/justinjrudio/var"
      }
    }
  ]

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


# resource "google_compute_disk" "foobar" {
#   name  = "existing-disk"
#   image = data.google_compute_image.my_image.self_link
#   size  = 10
#   type  = "pd-ssd"
#   zone  = "us-central1-a"
# }

# resource "google_compute_resource_policy" "daily_backup" {
#   name   = "every-day-4am"
#   region = "us-central1"
#   snapshot_schedule_policy {
#     schedule {
#       daily_schedule {
#         days_in_cycle = 1
#         start_time    = "04:00"
#       }
#     }
#   }
# }

locals {
  panel_name = "${var.service_name}-panel"
}