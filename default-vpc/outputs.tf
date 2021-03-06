output "lb_dns_name" {
  value = module.k3s.lb_dns_name
}

output "rds_username" {
  value = module.k3s.rds_username
}

output "mysql_password" {
  value = module.k3s.mysql_password
  sensitive = true
}

output "master_private_ips" {
  value = module.k3s.master_instance.*.private_ip
}

output "master_public_ips" {
  value = module.k3s.master_instance.*.public_ip
}