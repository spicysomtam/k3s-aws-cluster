locals {
  aurora_engine = "aurora-mysql"
  aurora_engine_version = "5.7.mysql_aurora.2.08.1"
}

resource "random_password" "mysql_password" {
  length  = 10
  special = false
}

resource "aws_db_subnet_group" "k3s" {
  name = "${var.prefix}k3s"
  subnet_ids = var.inst_subnet_ids
  tags = var.tags
}

resource "aws_db_instance" "k3s" {
  count                = var.use_aurora_db ? 0 : 1
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.38"
  db_subnet_group_name = aws_db_subnet_group.k3s.id
  instance_class       = var.rds_inst_type
  name                 = "${var.prefix}k3s"
  identifier           = "${var.prefix}k3s"
  username             = var.rds_username
  password             = random_password.mysql_password.result
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.k3s_mysql.id]
  skip_final_snapshot = true
  tags = var.tags
}

resource "aws_rds_cluster" "k3s" {
  count                   = var.use_aurora_db ? 1 : 0
  cluster_identifier      = "${var.prefix}k3s"
  engine                  = local.aurora_engine
  engine_version          = local.aurora_engine_version
  db_subnet_group_name    = aws_db_subnet_group.k3s.id
  database_name           = "${var.prefix}k3s"
  master_username         = var.rds_username
  master_password         = random_password.mysql_password.result
  vpc_security_group_ids = [ aws_security_group.k3s_mysql.id]
  skip_final_snapshot     = true
  tags                    = var.tags
}

resource "aws_rds_cluster_instance" "k3s" {
  count                   = var.use_aurora_db ? var.num_rds_instances : 0
  identifier              = "${var.prefix}k3s-${count.index}"
  engine                  = local.aurora_engine
  engine_version          = local.aurora_engine_version
  db_subnet_group_name    = aws_db_subnet_group.k3s.id
  cluster_identifier      = aws_rds_cluster.k3s[0].id
  instance_class          = var.rds_inst_type
  db_parameter_group_name = "default.aurora-mysql5.7"
}

resource "aws_security_group" "k3s_mysql" {
  name = "${var.prefix}-k3sRDS"
  description = "k3s rds mysql access"
  vpc_id      = var.vpc_id

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.master.id]
  }
  tags = merge(
    {
      Name = "${var.prefix}-k3sRDS"
    },
    var.tags,
  )
}
