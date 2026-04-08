output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "ansible_controller_public_ip" {
  description = "Public IP of the Ansible controller"
  value       = module.ansible_controller.public_ip
}

output "amazon_linux_private_ips" {
  description = "Private IPs of the Amazon Linux instances"
  value       = { for k, v in module.private_instances : k => v.private_ip if startswith(k, "amazon") }
}

output "ubuntu_private_ips" {
  description = "Private IPs of the Ubuntu instances"
  value       = { for k, v in module.private_instances : k => v.private_ip if startswith(k, "ubuntu") }
}
