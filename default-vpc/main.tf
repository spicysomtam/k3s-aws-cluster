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
  #source = "github.com/spicysomtam/k3s-aws-cluster-simple?ref=v1.0.x"
  source = "../"
  prefix = "k2"
  vpc_id = data.aws_vpc.default.id

  # Idea here is to put the load balancer on the pub subnets and the cluster/mysql on the private subnets so its secure.
  # For this simple example put them on the default vpc subnets.
  lb_subnet_ids = data.aws_subnet_ids.default.ids
  inst_subnet_ids = data.aws_subnet_ids.default.ids

  # Number of master nodes; 2 is recommended for fault tolerance; 1 if you just want a dev instance.
  m_num_servers = "2"

  # Number of agent/worker nodes; can be zero if you only want 2 masters.
  a_num_servers = "2"

  # ssh keypair for instances
  k3s_key_pair = "spicysomtam-aws4"
}