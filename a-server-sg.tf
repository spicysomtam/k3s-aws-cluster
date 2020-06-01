resource "aws_security_group" "agent" {
  name        = "${var.prefix}-k3sAgentServer"
  description = "k3s agent/worker ec2 instances"
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
      Name = "${var.prefix}-AgentServer"
    },
    var.tags,
  )
}