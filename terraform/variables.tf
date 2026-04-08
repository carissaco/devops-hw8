variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "hw8"
}

variable "ami_id" {
  description = "AMI ID built by Packer"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for bastion SSH access"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "AMI ID for Ubuntu instances built by Packer"
  type        = string
}
