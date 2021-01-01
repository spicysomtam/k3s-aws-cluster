output "master_instance" {
  value = aws_instance.master
}

output "agent_instance" {
  value = aws_autoscaling_group.agent
}

output "bastion_instance" {
  value = aws_instance.bastion
}

output "server_ssh_key" {
  value = var.k3s_key_pair
}

output "bastion_ssh_key" {
  value = var.b_key_pair
}

output "lb_dns_name" {
  value = var.lb_enabled ? aws_lb.lb[0].dns_name : null
}

output "lb_zone_id" {
  value = var.lb_enabled ? aws_lb.lb[0].zone_id : null
}

output "rds_username" {
  value = var.rds_username
}

output "mysql_password" {
  value = random_password.mysql_password.result
}

output "deployment_prefix" {
  value = var.prefix
}
