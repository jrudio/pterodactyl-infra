variable "project" {
  type = object({
    id     = string
    region = string
    zone   = string
  })
}

variable "game_servers" {
  type = list(
    object({
      instance_name = string
      region        = string
      zone          = string
      machine_type  = string
      disk_type     = string
      disk_size     = number
      ports = object({
        name  = string
        types = list(string)
        ports = list(string)
      })
    })
  )
}

variable "subnet_name_prefix" {
  type    = string
  default = "wings"
}

variable "network_name" {
  type    = string
  default = "pterodactyl-wings"
}

variable "allowed_ip_addresses" {
  type = object({
    ssh   = list(string)
    wings = list(string)
  })
  description = "List of IP adresses allowed to connect to wings or ssh"
}

variable "certificate_bucket_location" {
  type        = string
  default     = "US"
  description = "Multi-region bucket location of all of the wing's certificate"
  validation {
    condition     = contains(["US", "EU"], var.certificate_bucket_location)
    error_message = "The bucket location must be either US or EU."
  }
}