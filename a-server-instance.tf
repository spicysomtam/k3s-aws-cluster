resource "aws_instance" "agent" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.a_inst_type
  count = var.a_num_servers
  iam_instance_profile = aws_iam_instance_profile.k3s.name
  key_name = var.key_pair
  availability_zone = data.aws_availability_zones.available.names[count.index]
  security_groups = [aws_security_group.agent.name]

  user_data = templatefile("a-userdata.tmpl", { 
    host = aws_instance.master[0].private_ip, 
    token = random_password.k3s_cluster_secret.result
  })
  depends_on = [ aws_instance.master ]

  tags = {
    Name = "${var.prefix}-k3sAgent${count.index}"
  }
}
