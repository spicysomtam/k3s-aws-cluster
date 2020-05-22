
output "masters_public_ips" {
  value = [aws_instance.master.*.public_ip]
}

output "masters_private_ips" {
  value = [aws_instance.master.*.private_ip]
}

output "agents_public_ips" {
  value = [aws_instance.agent.*.public_ip]
}

output "agents_private_ips" {
  value = [aws_instance.agent.*.private_ip]
}

output "bastion_public_ip" {
  value = [aws_instance.bastion.*.public_ip]
}

output "bastion_private_ip" {
  value = [aws_instance.bastion.*.private_ip]
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

output "mysql_username" {
  value = var.mysql_username
}

output "mysql_password" {
  value = random_password.mysql_password.result
}

output "deployment_prefix" {
  value = var.prefix
}
