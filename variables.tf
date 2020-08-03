#
# Variables Configuration
#

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

variable "m_server_disk_size" {
  description = "Size of master server root device in Gb."
  default = "20"
}

variable "m_additional_sg" {
  description = "Additional sg's to attach to the master servers."
  default     = []
  type        = list(string)
}

variable "vpc_id" {
  description = "Id of vpc to deploy stack into."
}

# In some instances may wish to turn off the lb balancer; eg this does not fit your use case.
# We had a case where the user wanted to create their own internal load balancer providing access to just the k8s api
variable "lb_enabled" {
  description = "Whether the lb is enabled."
  type        = bool
  default     = true
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

variable "b_inst_type" {
  description = "Bastion server instance type."
  default     = "t3a.micro"
}

variable "a_server_disk_size" {
  description = "Size of agent server root device in Gb."
  default = "20"
}

variable "a_additional_sg" {
  description = "Additional sg's to attach to the agent servers."
  default     = []
  type        = list(string)
}

variable "bastion_enabled" {
  description = "Whether bastion server is created."
  default = false
  type = bool
}

variable "kubeconfig_on_console" {
  description = "Whether kubeconfig should be sent to master0 console."
  default     = "0"
}

variable "api_on_lb" {
  description = "Whether k8s api should be exposed on the load balancer."
  type = bool
  default = true
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

# Allowing k3s cluster access from everything is probably not secure; so please override this to your requirement.
variable "k3s_ssh_ingress_cidrs" {
  description = "External ips allowed access to all k3s servers via ssh."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# Allowing bastion access from everything is probably not secure; so please override this to your requirement.
variable "b_ssh_ingress_cidrs" {
  description = "External ips allowed access to the bastion via ssh."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "k3s_key_pair" {
  description = "aws key pair to access all k3s servers."
  default = "my-keypair"
}

variable "b_key_pair" {
  description = "aws key pair to access bastion."
  default = "my-keypair"
}

variable "rds_inst_type" {
  default = "db.t3.small"
}

# How many aurora instances to create; aws recommends 2 for mysql (1 writer 1 reader).
# aws will automatically put them in different AZs.
# If you need more instances increase > 2; in reality this means 1 writer and multiple readers althought the role can be moved around by aws. 
variable "num_rds_instances" {
  default = 2
}

variable "rds_username" {
  default = "admin"
}

# This stack defaults to using mysql community. 
# Aurora offers approx 5x performance improvement over mysql community and storage fault tolerance across multiple AZs by default.
# For testing I would stick with mysql; for a production setup use aurora.
variable "use_aurora_db" {
  description = "Whether to use aurora mysql instead of community mysql."
  default = false
  type = bool
}

variable "tags" {
  type        = map(string)
  default     = {}
}

