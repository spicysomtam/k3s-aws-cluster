resource "aws_security_group" "master" {
  name        = "${var.prefix}-k3sMasterServer"
  description = "k3s master ec2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.k3s_ssh_ingress_cidrs
  }

  # treafik ingress controller tends to bounce http to https.
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.https_ingress_cidrs
  } 

  ingress {
    description = "HTTPS"
    from_port   = 443 
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.https_ingress_cidrs
  } 

  ingress {
    description = "K8SAPI"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.api_ingress_cidrs
  }

  ingress {
    description = "Full vpc access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.prefix}-MasterServer"
    },
    var.tags
  )
}