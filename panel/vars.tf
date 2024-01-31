variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "zone" {
  type    = string
  default = "us-west1-a"
}

variable "web_app_machine_type" {
  type    = string
  default = "e2-small"

  # validation {
  #   condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
  #   error_message = "the machine type for the database must be one of: e2-micro, e2-small, or e2-medium"
  # }
}

variable "service_name" {
  type        = string
  description = "Name of the service"
  default     = "pterodactyl"
}

variable "tf_bucket" {
  type = object({
    name   = string,
    region = string
  })
  description = "google cloud storage bucket for terraform state"
}
