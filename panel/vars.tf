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

  # validation {
  #   condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
  #   error_message = "the machine type for the database must be one of: e2-micro, e2-small, or e2-medium"
  # }
}

variable "service_name" {
  type = string
  description = "Name of the service"
  default = "pterodactyl"
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

variable "database_name" {
  type    = string
  default = "pterodactyl-ui-db"
}

variable "database_user_email" {
  type = string
}

variable "panel_network" {
  type    = string
  default = "pterodactyl"
}

variable "panel_subnet" {
  type    = string
  default = "pterodactyl-db-net"
}

variable "panel_subnet_range" {
  type    = string
  default = "10.0.1.0/24"
}

variable "panel_connector_subnet" {
  type    = string
  default = "pterodactyl-connector-net"
}


variable "connector_subnet_range" {
  type    = string
  default = "10.8.0.0/28"
}

variable "panel_connector_dev_subnet" {
  type    = string
  default = "pterodactyl-connector-dev-net"
}

variable "connector_dev_subnet_range" {
  type    = string
  default = "10.9.0.0/28"
}

variable "router_name" {
  type    = string
  default = "pterodactyl-router"
}

variable "nat_name" {
  type    = string
  default = "pterodactyl-nat"
}
