variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "zone" {
  type    = string
  default = "us-west1-b"
}

variable "machine_type" {
  type    = string
  default = "e2-small"

  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
    error_message = "the machine type for the database must be one of: e2-micro, e2-small, or e2-medium"
  }
}

variable "db_instance_name" {
  type    = string
  default = "pterodactyl-db"
}

variable "db_instance_ip" {
  type        = string
  description = "reserved internal ip for the database instance"
  default     = "10.0.1.4"
}