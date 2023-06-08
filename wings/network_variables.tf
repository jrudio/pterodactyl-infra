variable "wing_network" {
  type    = string
  default = "pterodactyl-wing"
}

variable "wing_subnet" {
  type    = string
  default = "pterodactyl-wing-db-net"
}

# variable "router_name" {
#   type    = string
#   default = "pterodactyl-wing-router"
# }

# variable "nat_name" {
#   type    = string
#   default = "pterodactyl-wing-nat"
# }

variable "firewall_rules" {
  type = map(string)
  default = {
    wing      = "allow-wing-daemon"
    rust_game = "allow-rust"
    ssh       = "allow-ssh-for-user"
  }
}

variable "allowed_ssh_ip" {
  type = string
}