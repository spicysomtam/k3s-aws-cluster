resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.b_inst_type
  count = var.bastion_enabled
  #iam_instance_profile = aws_iam_instance_profile.k3s.name
  key_name = var.b_key_pair
  subnet_id = var.lb_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.prefix}-k3sBastion${count.index}"
  }
}
