provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "k3s" {
  # Use this if pulling module from github
  #source = "github.com/spicysomtam/k3s-aws-cluster?ref=v1.0.x"
  source = "../"
  prefix = var.prefix
  vpc_id = data.aws_vpc.default.id

  # Idea here is to put the load balancer on the pub subnets and the cluster/mysql on the private subnets so its secure.
  # For this simple example put them on the default vpc subnets.
  lb_subnet_ids = data.aws_subnet_ids.default.ids
  inst_subnet_ids = data.aws_subnet_ids.default.ids

  # Number of master nodes; 2 is recommended for fault tolerance; 1 if you just want a dev instance.
  m_num_servers = var.m_num_servers

  # Master instance type
  m_inst_type = var.m_inst_type

  # Number of agent/worker nodes; can be zero if you only want 2 masters.
  a_num_servers = var.a_num_servers

  # Agent instance type
  a_inst_type = var.a_inst_type

  # ssh keypair for instances
  k3s_key_pair = var.key_pair

  # Whether to display kubeconfig on console of master0 (0=false (default); 1=true)
  kubeconfig_on_console = true

  # Use aurordb mysql rather than mysql community?
  use_aurora_db = false

  bastion_enabled = var.bastion_enabled
  b_key_pair = var.key_pair

  tags = var.tags
}
