
/*
output "api_url" {
  value = "https://${var.rancher_dns_name}"
}
*/

output "masters_public_ips" {
  value = [aws_instance.master.*.public_ip]
}

output "agents_public_ips" {
  value = [aws_instance.agent.*.public_ip]
}
output "server_ssh_key" {
  value = var.key_pair
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