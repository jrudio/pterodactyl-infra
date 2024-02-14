locals {
  wing_template_tag = "wing"
  instance_os       = "ubuntu-os-cloud/ubuntu-2204-lts"
}

resource "google_service_account" "wing" {
  account_id   = "pterodactyl-wing"
  display_name = "Service Account for Pterodactyl wings"
}

resource "google_compute_instance_template" "wing" {
  for_each    = { for i, server in var.game_servers : i => server }
  name        = "wing-template"
  description = "This template is used to create a Pterodactyl wing"
  region      = each.value.region

  tags = [local.wing_template_tag]

  labels = {
    environment = "dev"
  }

  instance_description = "Pterodactyl wing"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    #   source      = google_compute_disk.wing_boot[each.key].self_link
    #   auto_delete = false
    #   boot        = true
    #   resource_policies = [
    #     google_compute_resource_policy.daily_backup[each.key].self_link
    #   ]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.wing_subnet[each.key].self_link # override subnet when creating a wing

    access_config {
      // give the instance a public ip

    }
  }

  metadata = {
    service = "wings"
  }

  metadata_startup_script = data.local_file.startup_script.content

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.wing.email
    scopes = ["cloud-platform"]
  }
}

data "local_file" "startup_script" {
  filename = "${path.module}/startup_script.sh"
}


resource "google_compute_disk" "wing_boot" {
  provider = google-beta
  for_each = { for i, server in var.game_servers : i => server }
  name     = "wing-boot-disk-${each.value.instance_name}"
  image    = local.instance_os
  size     = each.value.disk_size
  type     = each.value.disk_type
  zone     = each.value.zone
  resource_policies = [
    google_compute_resource_policy.daily_backup[each.key].self_link
  ]
}

resource "google_compute_resource_policy" "daily_backup" {
  for_each = { for i, server in var.game_servers : i => server }
  name     = "daily-4am"
  region   = each.value.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 4
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}
