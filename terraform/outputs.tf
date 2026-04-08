output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the 6 private instances"
  value       = module.private_instances[*].private_ip
}
