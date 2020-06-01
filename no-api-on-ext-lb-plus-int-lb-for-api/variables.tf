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

variable "api_lb_internal" {
  description = "Whether api lb is internal."
  default = true
  type = bool
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "api_ingress_cidrs" {
  description = "External ips allowed access to k3s api."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "tags" {
  default = {
    Terraform = "true"
    Environment = "k3"
  }
}