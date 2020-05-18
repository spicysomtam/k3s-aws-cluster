resource "aws_instance" "master" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.m_inst_type
  count = var.m_num_servers
  iam_instance_profile = aws_iam_instance_profile.k3s.name
  key_name = var.key_pair
  availability_zone = data.aws_availability_zones.available.names[count.index]
  security_groups = [aws_security_group.master.name]

  user_data = templatefile("m-userdata.tmpl", { 
    pwd = random_password.mysql_password.result, 
    host = aws_db_instance.k3s.address, 
    inst-id = count.index,
    token = random_password.k3s_cluster_secret.result
  })
  depends_on = [ aws_db_instance.k3s, aws_security_group.k3s_mysql ]

  tags = {
    Name = "${var.prefix}-k3sMaster${count.index}"
  }
}
