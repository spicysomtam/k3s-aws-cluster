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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "api_lb_dns_name" {
  value = aws_lb.api_lb.dns_name
}

output "bastion_public_ip" {
  value = length(module.k3s.bastion_instance) > 0 ? module.k3s.bastion_instance[0].public_ip : null
}

output "master_private_ips" {
  value = module.k3s.master_instance.*.private_ip
}
