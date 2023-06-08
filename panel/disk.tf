# resource "google_compute_disk" "data_disk" {
#   name = var.data_disk_name
#   type = var.data_disk_type
#   zone = var.zone
#   size = 10
#   labels = {
#     environment = "dev"
#     name        = "pterodactyl_data"
#   }
#   snapshot = var.data_disk_snapshot
# }

# resource "google_compute_attached_disk" "data_disk_attached" {
#   disk     = google_compute_disk.data_disk.id
#   instance = google_compute_instance.database.id
# }

# resource "google_compute_disk_resource_policy_attachment" "data_disk_attachment_policy" {
#   name = google_compute_resource_policy.data_disk_daily_snapshots.name
#   disk = google_compute_disk.data_disk.name
#   zone = var.zone
# }

# resource "google_compute_resource_policy" "data_disk_daily_snapshots" {
#   name        = "${var.data_disk_name}-snaphot-schedule"
#   region      = var.region
#   description = "database snapshot schedule"
#   snapshot_schedule_policy {
#     schedule {
#       daily_schedule {
#         days_in_cycle = 1
#         start_time    = "10:00"
#       }
#     }
#     retention_policy {
#       max_retention_days    = 7
#       on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
#     }
#     snapshot_properties {
#       labels = {
#         environment = "dev"
#       }
#       storage_locations = [var.region]
#       guest_flush       = false
#       chain_name        = "${google_compute_disk.data_disk.name}-${var.region}"
#     }
#   }
# }