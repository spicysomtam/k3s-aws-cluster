output "master_instance" {
  value = aws_instance.master
}

output "agent_instance" {
  value = aws_instance.agent
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
  value = aws_lb.lb.dns_name
}

output "rds_username" {
  value = var.rds_username
}

output "rds_password" {
  value = random_password.rds_password.result
}

output "deployment_prefix" {
  value = var.prefix
}
