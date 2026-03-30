variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ami_id" {
  description = "AMI ID built by Packer"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for bastion SSH access"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the bastion host"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the private instances"
  type        = list(string)
}
