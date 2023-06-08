variable "data_disk_name" {
  type    = string
  default = "pterodactyl-data"
}

variable "data_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "data_disk_snapshot" {
  type = string
}