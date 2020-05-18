resource "random_password" "mysql_password" {
  length  = 10
  special = false
}

resource "aws_db_instance" "k3s" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = var.mysql_inst_type
  name                 = "${var.prefix}k3s"
  identifier           = "${var.prefix}k3s"
  username             = var.mysql_username
  password             = random_password.mysql_password.result
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.k3s_mysql.id]
  skip_final_snapshot = true
}

resource "aws_security_group" "k3s_mysql" {
  name = "${var.prefix}-k3sRDS"

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.master.id]
  }
  tags = {
    Name = "${var.prefix}-k3sRDS"
  }
}