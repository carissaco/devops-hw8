output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.ec2.bastion_public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the 6 private instances"
  value       = module.ec2.private_instance_ips
}

output "prometheus_private_ip" {
  description = "Private IP of the Prometheus instance"
  value       = module.ec2.prometheus_private_ip
}

output "grafana_private_ip" {
  description = "Private IP of the Grafana instance"
  value       = module.ec2.grafana_private_ip
}
