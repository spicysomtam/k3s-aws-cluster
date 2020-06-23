resource "aws_instance" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  ami = data.aws_ami.ubuntu.id
  instance_type = var.b_inst_type
  key_name = var.b_key_pair
  subnet_id = var.lb_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.bastion[0].id]

  tags = merge(
    {
      Name = "${var.prefix}-k3sBastion${count.index}"
    },
    var.tags,
  )
}
