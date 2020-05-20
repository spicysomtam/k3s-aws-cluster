#
# Variables Configuration
#

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for deploy for aws resources`."
}

variable "m_inst_type" {
  description = "Master server instance type."
  default     = "t3a.medium"
}

variable "m_num_servers" {
  description = "Number of master server instances to deploy (2 recommended)."
  default = "2"
}

variable "vpc_id" {
  description = "Id of vpc to deploy stack into."
}

variable "lb_subnet_ids" {
  description = "List of subnet ids to attach the lb."
  type        = list(string)
}

variable "inst_subnet_ids" {
  description = "List of subnet ids to launch k3s instances."
  type        = list(string)
}

variable "a_inst_type" {
  description = "Agent/worker server instance type."
  default     = "t3a.medium"
}

variable "a_num_servers" {
  description = "Number of agent/worker server instances to deploy."
  default = "2"
}

variable "lb_internal" {
  description = "Whether lb is internal."
  default = false
  type = bool
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "api_ingress_cidrs" {
  description = "External ips allowed access to k3s api."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "https_ingress_cidrs" {
  description = "External ips allowed access to k3s the ingress controller on http/https."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "ssh_ingress_cidrs" {
  description = "External ips allowed access to all servers via ssh."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "key_pair" {
  description = "aws key pair to access all k3s servers."
  default = "my-keypair"
}

variable "mysql_inst_type" {
  default = "db.t2.micro"
}

variable "mysql_username" {
  default = "admin"
}
