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
    # list will be expanded for prod environments, but testing for now
    condition     = contains(["e2-micro", "e2-small", "e2-medium", "e2-standard-2"], var.machine_type)
    error_message = "the machine type for the wing server must be one of: e2-micro, e2-small, e2-medium, or e2-standard-2"
  }
}

variable "instance_prefix" {
  type    = string
  default = "wing-server"
}

variable "subnet_range" {
  type    = string
  default = "10.0.1.0/24"
}