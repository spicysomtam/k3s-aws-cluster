resource "aws_instance" "master" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.m_inst_type
  count = var.m_num_servers
  iam_instance_profile = aws_iam_instance_profile.k3s.name
  key_name = var.k3s_key_pair
  subnet_id = var.inst_subnet_ids[ count.index % length(var.inst_subnet_ids) ]
  vpc_security_group_ids = concat([aws_security_group.master.id], var.m_additional_sg)

  user_data = templatefile("${path.module}/m-userdata.tmpl", { 
    pwd = random_password.mysql_password.result, 
    host = var.use_aurora_db ? aws_rds_cluster.k3s[0].endpoint : aws_db_instance.k3s[0].address, 
    inst-id = count.index,
    kubeconfig-console = var.kubeconfig_on_console,
    kubeconfig-ssm = var.kubeconfig_ssm,
    prefix = var.prefix,
    token = random_password.k3s_cluster_secret.result
  })
  depends_on = [ aws_db_instance.k3s, aws_rds_cluster_instance.k3s, aws_security_group.k3s_mysql ]

  lifecycle {
    ignore_changes = all
  }

  root_block_device {
    volume_size = var.m_server_disk_size
  }

  tags = merge(
    {
      Name = "${var.prefix}-k3sMaster${count.index}"
    },
    var.tags,
  )
}
