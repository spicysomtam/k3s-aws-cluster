#
# Variables Configuration
#

variable "prefix" {
  description = "Prefix for deploy for aws resources`."
  default = "k3"
}

# Assume /16 class B network; this gets chopped up into subnets.
variable "vpc_cidr_prefix" {
  default = "172.33"
}
variable "m_num_servers" {
  description = "Number of master server instances to deploy (2 recommended)."
  default = "2"
}

variable "a_num_servers" {
  description = "Number of agent/worker server instances to deploy."
  default = "2"
}

variable "tags" {
  default = {
    Terraform = "true"
    Environment = "k3"
  }
}
