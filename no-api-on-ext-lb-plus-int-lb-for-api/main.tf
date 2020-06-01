locals {
  private_subnet_cidrs = ["${var.vpc_cidr_prefix}.48.0/20", "${var.vpc_cidr_prefix}.64.0/20", "${var.vpc_cidr_prefix}.80.0/20"]
  public_subnet_cidrs  = ["${var.vpc_cidr_prefix}.0.0/20", "${var.vpc_cidr_prefix}.16.0/20", "${var.vpc_cidr_prefix}.32.0/20"]
}

resource "aws_eip" "nat" {
  count = 3
  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = var.prefix
  cidr = "${var.vpc_cidr_prefix}.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = local.private_subnet_cidrs
  public_subnets = local.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway  = false
  one_nat_gateway_per_az = false
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id

  enable_vpn_gateway = true

  tags = var.tags
}

module "k3s" {
  # Use this if pulling module from github
  #source = "github.com/spicysomtam/k3s-aws-cluster-simple?ref=v1.0.x"
  source = "../"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id

  # Idea here is to put the load balancer on the pub subnets and the cluster/mysql on the private subnets so its secure.
  # For this simple example put them on the default vpc subnets.
  lb_subnet_ids = module.vpc.public_subnets
  inst_subnet_ids = module.vpc.private_subnets

  # Number of master nodes; 2 is recommended for fault tolerance; 1 if you just want a dev instance.
  m_num_servers = var.m_num_servers

  # Number of agent/worker nodes; can be zero if you only want 2 masters.
  a_num_servers = var.a_num_servers

  # ssh keypair for instances
  k3s_key_pair = "spicysomtam-aws4"

  # enable bastion so we can get to hosts in priv subnets
  bastion_enabled = "1"
  b_key_pair = "spicysomtam-aws4"

  # no api on ext lb
  api_on_lb = false

  # An example of restricting the k8s api to a vpn or management network range
  api_ingress_cidrs = [ "18.0.0.0/16" ]

  # Whether to display kubeconfig on console of master0 (0=false (default); 1=true)
  kubeconfig_on_console = "1"

  tags = var.tags
}
