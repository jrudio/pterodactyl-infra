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

variable "firewall_rules" {
  type = map(string)
  default = {
    iap   = "allow-ssh-over-iap-pterodactyl"
    redis = "allow-redis-ingress-pterodactyl"
    mysql = "allow-mysql-ingress-pterodactyl"
  }
}

variable "serverless_connector" {
  type = map(string)
  default = {
    name         = "pterodactyl-connector"
    machine_type = "f1-micro"
  }
}

variable "serverless_connector_dev" {
  type = map(string)
  default = {
    name         = "pterodactyl-connector-dev"
    machine_type = "f1-micro"
  }
}