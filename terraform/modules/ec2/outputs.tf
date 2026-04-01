output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_instance_ips" {
  value = aws_instance.private[*].private_ip
}

output "prometheus_private_ip" {
  value = aws_instance.prometheus.private_ip
}

output "grafana_private_ip" {
  value = aws_instance.grafana.private_ip
}
