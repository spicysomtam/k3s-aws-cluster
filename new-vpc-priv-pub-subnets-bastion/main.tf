resource "aws_eip" "nat" {
  count = 3
  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "k3"
  cidr = "172.33.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["172.33.24.0/21", "172.33.32.0/21", "172.33.40.0/21" ]
  public_subnets = ["172.33.0.0/21", "172.33.8.0/21", "172.33.16.0/21" ]

  enable_nat_gateway = true
  single_nat_gateway  = false
  one_nat_gateway_per_az = false
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id

  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "k3"
  }
}

module "k3s" {
  # Use this if pulling module from github
  #source = "github.com/spicysomtam/k3s-aws-cluster-simple?ref=v1.0.x"
  source = "../"
  prefix = "k3"
  vpc_id = module.vpc.vpc_id

  # Idea here is to put the load balancer on the pub subnets and the cluster/mysql on the private subnets so its secure.
  # For this simple example put them on the default vpc subnets.
  lb_subnet_ids = module.vpc.public_subnets
  inst_subnet_ids = module.vpc.private_subnets

  # Number of master nodes; 2 is recommended for fault tolerance; 1 if you just want a dev instance.
  m_num_servers = "2"

  # Number of agent/worker nodes; can be zero if you only want 2 masters.
  a_num_servers = "2"

  # ssh keypair for instances
  k3s_key_pair = "spicysomtam-aws4"

  bastion_enabled = "1"
  b_key_pair = "spicysomtam-aws4"
}

output "lb_dns_name" {
  value = module.k3s.lb_dns_name
}

output "mysql_username" {
  value = module.k3s.mysql_username
}

output "mysql_password" {
  value = module.k3s.mysql_password
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "deployment_prefix" {
  value = module.k3s.prefix
}
