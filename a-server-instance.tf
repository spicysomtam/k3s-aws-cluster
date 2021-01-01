resource "aws_launch_template" "agent" {
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.a_inst_type

  iam_instance_profile {
    name = aws_iam_instance_profile.k3s.name
  }

  key_name = var.k3s_key_pair

  user_data = base64encode(templatefile("${path.module}/a-userdata.tmpl", { 
    host = aws_instance.master[0].private_ip, 
    token = random_password.k3s_cluster_secret.result
  }))

  depends_on = [ aws_instance.master ]

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.a_server_disk_size
    }
  }

  # Ignore changes on a new ami shipped by aws
  lifecycle {
    ignore_changes = [
      image_id,
      user_data,
    ]
  }
}

resource "aws_autoscaling_group" "agent" {
  desired_capacity   = var.a_num_servers
  max_size           = var.a_max_servers
  min_size           = var.a_num_servers

  launch_template {
    id      = aws_launch_template.agent.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.inst_subnet_ids

  tags = [
    {
      "key" = "Name"
      "value" = "${var.prefix}-k3sAgent"
      "propagate_at_launch" = true
    },
    {
      "key" = "Terraform"
      "value" = "true"
      "propagate_at_launch" = true
    },
  ]


}

/*
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
      user_data,
    ]
  }

  tags = merge(
    {
      Name = "${var.prefix}-k3sAgent${count.index}"
    },
    var.tags,
  )
}
*/