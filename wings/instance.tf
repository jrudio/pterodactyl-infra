resource "google_compute_address" "wing" {
  for_each     = { for i, server in var.game_servers : i => server }
  name         = "${each.value.instance_name}-ip"
  address_type = "EXTERNAL"
  region       = each.value.region

}

resource "google_compute_instance_from_template" "wing" {
  for_each     = { for i, server in var.game_servers : i => server }
  name         = each.value.instance_name
  zone         = each.value.zone
  machine_type = each.value.machine_type

  source_instance_template = google_compute_instance_template.wing[each.key].self_link

  tags = [
    local.wing_template_tag,
    "${var.network_name}-${each.value.instance_name}-${each.value.zone}"
  ]

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.wing_boot[each.key].self_link
  }


  network_interface {
    subnetwork = "${var.subnet_name_prefix}-${each.value.region}"

    access_config {
      // give the instance a public ip
      nat_ip = google_compute_address.wing[each.key].address
    }
  }

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    tier = "basic"
  }

  allow_stopping_for_update = true
}

