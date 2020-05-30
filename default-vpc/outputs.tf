output "lb_dns_name" {
  value = module.k3s.lb_dns_name
}

output "mysql_username" {
  value = module.k3s.mysql_username
}

output "mysql_password" {
  value = module.k3s.mysql_password
}

output "master_public_ips" {
  value = module.k3s.master_instance.*.public_ip
}

output "agent_public_ips" {
  value = module.k3s.agent_instance.*.public_ip
}
