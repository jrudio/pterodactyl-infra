locals {
  db_name               = "${var.service_name}-db"
  db_health_check_delay = 130
  # set 'db_init_script' to a multi-line string
  db_init_script_host_path = "/tmp"
  db_init_script           = <<EOF
#!/bin/bash

# check if mysql is installed
if ! hash mysql 2>/dev/null; then
  echo \"MySQL is not installed\"
  exit 1
fi

# check if mysql_database is empty
if [ -z \"\$MYSQL_DATABASE\" ]; then
  echo \"env MYSQL_DATABASE is required\"
  exit 1
fi

if [ -z \"\$MYSQL_USER\" ]; then
  echo \"env MYSQL_USER is required\"
  exit 1
fi

if [ -z \"\$MYSQL_PASSWORD\" ]; then
  echo \"env MYSQL_PASSWORD is required\"
  exit 1
fi

if [ -z \"\$MYSQL_ROOT_PASSWORD\" ]; then
  echo \"could not find mysql root password\"
  exit 1
fi

# create new database using mysql command line and print the status
echo \"creating new database '$MYSQL_DATABASE'...\"
mysql -uroot -p\$MYSQL_ROOT_PASSWORD -e \"CREATE DATABASE IF NOT EXISTS \$MYSQL_DATABASE\"

echo "creating new user '$MYSQL_USER'..."
mysql -uroot -p\$MYSQL_ROOT_PASSWORD -e \"CREATE USER '\$MYSQL_USER'@'%' IDENTIFIED BY '\$MYSQL_PASSWORD'\"

echo \"granting privileges...\"
mysql -uroot -p\$MYSQL_ROOT_PASSWORD -e \"GRANT ALL PRIVILEGES ON *.* TO '\$MYSQL_USER'@'%';\"

echo \"flushing privileges...\"
mysql -uroot -p\$MYSQL_ROOT_PASSWORD -e \"FLUSH PRIVILEGES;\"

echo \"finished mysql init stuff.\"
EOF
}

resource "google_service_account" "db" {
  account_id   = "${var.service_name}-db"
  display_name = "${title(join(" ", split("-", var.service_name)))} Database"
}

resource "google_compute_address" "db" {
  name         = local.db_name
  description  = "Static internal IP address used for the database"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.panel_subnet.id
}

resource "google_compute_instance_group_manager" "db" {
  provider = google-beta
  name     = "${var.service_name}-db-igm"

  base_instance_name = "${var.service_name}-db"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.db.self_link_unique
  }

  stateful_disk {
    device_name = google_compute_disk.db_data.name
    delete_rule = "NEVER"
  }

  target_size = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.db.id
    initial_delay_sec = local.db_health_check_delay
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    replacement_method    = "RECREATE"
    max_surge_fixed       = 0
    max_unavailable_fixed = 1
  }
}

resource "google_compute_instance_template" "db" {
  name_prefix = "${local.db_name}-"
  description = "Template for the database that stores Pterodactyl panel data"

  tags = [local.firewall_rules.iap, local.db_name]

  labels = {
    environment = var.environment
    service     = var.service_name
  }

  instance_description = "Database server for Pterodactyl"
  machine_type         = var.db_machine_type
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

  // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    device_name       = google_compute_disk.db_data.name
    source            = google_compute_disk.db_data.name
    auto_delete       = false
    boot              = false
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.panel_subnet.id
    network_ip = google_compute_address.db.address
  }

  metadata = {
    "gce-container-declaration" = module.gce-container-db.metadata_value
  }

  metadata_startup_script = "echo \"${local.db_init_script}\" > ${local.db_init_script_host_path}/init_mysql_user.sh"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.db.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "gce-container-db" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.1"

  container = {
    image = var.db_container_image
    env = [
      {
        name  = "MYSQL_DATABASE"
        value = "panel"
      },
      {
        name  = "MYSQL_USER"
        value = "pterodactyl"
      },
      {
        name  = "MYSQL_PASSWORD"
        value = var.db.pterodactyl_password
      },
      {
        name  = "MYSQL_ROOT_PASSWORD"
        value = var.db.root_password
      },
      # {
      #   name  = "MYSQL_RANDOM_ROOT_PASSWORD"
      #   value = "true"
      # },
      # {
      #   name  = "MYSQL_ROOT_HOST",
      #   value = "0.0.0.0"
      # }
    ]

    volumeMounts = [
      {
        mountPath = "/var/lib/mysql"
        name      = google_compute_disk.db_data.name
      }
    ]
  }

  volumes = [
    {
      name = google_compute_disk.db_data.name

      gcePersistentDisk = {
        pdName = google_compute_disk.db_data.name
        fsType = "ext4"
      }
    }
  ]

  restart_policy = "Always"
}

resource "google_compute_health_check" "db" {
  name                = "${local.db_name}-autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  tcp_health_check {
    port = "3306"
  }
}


resource "google_compute_disk" "db_data" {
  provider = google-beta
  name     = "${local.db_name}-data-disk"
  size     = 15
  type     = var.database_data_disk_type
  zone     = var.zone
  snapshot = local.db_snapshot_name != "null" ? local.db_snapshot_name : null
  resource_policies = [
    google_compute_resource_policy.daily_backup.id
  ]
}

data "google_compute_snapshot" "db_snapshot" {
  name = var.database_data_disk_from_snapshot != "" ? var.database_data_disk_from_snapshot : "null"
}

locals {
  db_snapshot_name = data.google_compute_snapshot.db_snapshot.name
}

resource "google_compute_resource_policy" "daily_backup" {
  name   = "every-day-4am"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
  }
}
