#
# Variables Configuration
#

variable "key_pair" {
  description = "Keypair to use for ec2 instances."
  default = "spicysomtam-aws4"
}

variable "prefix" {
  description = "Prefix for deploy for aws resources`."
  default = "k3"
}

variable "m_num_servers" {
  description = "Number of master server instances to deploy (2 recommended)."
  default = "2"
}

variable "a_num_servers" {
  description = "Number of agent/worker server instances to deploy."
  default = "2"
}

variable "bastion_enabled" {
  default = true
  type = bool
}

variable "tags" {
  default = {
    Terraform = "true"
  }
}
