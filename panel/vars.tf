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

variable "panel_machine_type" {
  type    = string
  default = "e2-small"

  # validation {
  #   condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
  #   error_message = "the machine type for the database must be one of: e2-micro, e2-small, or e2-medium"
  # }
}

variable "db_machine_type" {
  type    = string
  default = "e2-small"

  # validation {
  #   condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
  #   error_message = "the machine type for the database must be one of: e2-micro, e2-small, or e2-medium"
  # }
}

variable "cache_machine_type" {
  type    = string
  default = "e2-micro"

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

variable "panel_container_image" {
  type        = string
  description = "Container image name for the panel"
}

variable "db_container_image" {
  type        = string
  description = "Container image name for the panel database. E.g. mariadb:lts"
}

variable "cache_container_image" {
  type        = string
  description = "Container image name for the panel cache. E.g. mariadb:lts"
}

variable "environment" {
  type        = string
  description = "The environment we are deploying to: dev, uat, pre-prod, prod"
  validation {
    condition     = contains(["dev", "uat", "pre-prod", "prod"], var.environment)
    error_message = "value must be one of: dev, uat, pre-prod, prod"
  }
}

variable "tf_bucket" {
  type = object({
    name   = string,
    region = string
  })
  description = "google cloud storage bucket for terraform state"
}

variable "panel" {
  type = object({
    url            = string,
    service_author = string
    timezone       = string
  })
  description = "Pterodactyl panel settings"
}

variable "load_balancer_domain" {
  type        = string
  description = "Domain name for the load balancer"
}