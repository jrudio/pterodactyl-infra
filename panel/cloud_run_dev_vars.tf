variable "cloud_run_dev_service_name" {
  type    = string
  default = "pterodactyl-ui-dev"
}
variable "cloud_run_dev_memory" {
  type    = string
  default = "512mi"
}

variable "cloud_run_dev_image" {
  type = string
}

variable "panel_dev_domain" {
  type = string
}