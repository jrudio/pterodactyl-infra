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
    url                = string,
    service_author     = string
    timezone           = string
    static_ip          = string
    bucket_name_prefix = string
  })
  description = "Pterodactyl panel settings. url sets APP_URL; it's what Pterodactyl expects to run under .\nUse static_ip if you already have a static ip provisioned and associated with your google cloud project"
}

variable "db" {
  type = object({
    pterodactyl_password = string
    root_password        = string
  })
  description = "required settings for MySQL"
}

variable "database_data_disk_type" {
  type        = string
  description = "Type of disk used for the database. Defaults to pd-balanced"
  default     = "pd-balanced"
  validation {
    condition     = contains(["pd-balanced", "pd-ssd", "pd-standard", "pd-extreme"], var.database_data_disk_type)
    error_message = "value must be one of: pd-balanced, pd-ssd, pd-standard, pd-extreme"
  }
}

variable "database_data_disk_from_snapshot" {
  type        = string
  description = "Optional - Name of snapshot related to db data disk. Provide empty string if empty disk is desired"
}