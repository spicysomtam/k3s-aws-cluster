resource "aws_security_group" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  name        = "${var.prefix}-k3sBastionServer"
  description = "k3s bastion ec2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.b_ssh_ingress_cidrs
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
      Name = "${var.prefix}-BastionServer"
    },
    var.tags
  )
}