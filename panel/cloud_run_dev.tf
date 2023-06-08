resource "google_cloud_run_v2_service" "panel_ui_dev" {
  name     = var.cloud_run_dev_service_name
  location = var.region
  client   = "terraform"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN1"
    containers {
      image = var.cloud_run_dev_image
    }

    vpc_access {
      connector = google_vpc_access_connector.connector_dev.id

      egress = "PRIVATE_RANGES_ONLY"
    }

    scaling {
      max_instance_count = 2
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_cloud_run_service_iam_binding" "panel_ui_dev_binding" {
  location = google_cloud_run_v2_service.panel_ui_dev.location
  service  = google_cloud_run_v2_service.panel_ui_dev.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_cloud_run_domain_mapping" "panel_ui_dev_domain" {
  location = var.region
  name     = var.panel_dev_domain

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.panel_ui_dev.name
  }
}