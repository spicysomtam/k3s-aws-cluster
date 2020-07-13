resource "aws_instance" "agent" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.a_inst_type
  count = var.a_num_servers
  iam_instance_profile = aws_iam_instance_profile.k3s.name
  key_name = var.k3s_key_pair
  subnet_id = var.inst_subnet_ids[ count.index % length(var.inst_subnet_ids) ]
  vpc_security_group_ids = concat([aws_security_group.agent.id], var.a_additional_sg)

  user_data = templatefile("${path.module}/a-userdata.tmpl", { 
    host = aws_instance.master[0].private_ip, 
    token = random_password.k3s_cluster_secret.result
  })
  depends_on = [ aws_instance.master ]

  root_block_device {
    volume_size = var.a_server_disk_size
  }

  # Ignore changes on a new ami shipped by aws
  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = merge(
    {
      Name = "${var.prefix}-k3sAgent${count.index}"
    },
    var.tags,
  )
}
