resource "google_cloud_run_v2_service" "panel_ui" {
  name     = var.cloud_run_service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN1"
    containers {
      image = var.cloud_run_image
    }

    vpc_access {
      connector = google_vpc_access_connector.connector.id

      egress = "PRIVATE_RANGES_ONLY"
    }

    scaling {
      max_instance_count = 2
    }
  }
}

resource "google_cloud_run_service_iam_binding" "panel_ui_binding" {
  location = google_cloud_run_v2_service.panel_ui.location
  service  = google_cloud_run_v2_service.panel_ui.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_cloud_run_domain_mapping" "panel_ui_domain" {
  location = var.region
  name     = var.panel_domain

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.panel_ui.name
  }
}