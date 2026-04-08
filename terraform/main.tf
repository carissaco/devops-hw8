provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = var.project_name
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH only from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_security_group" "ansible_controller" {
  name        = "${var.project_name}-ansible-sg"
  description = "Allow SSH from my IP for Ansible controller"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ansible-sg"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "Allow SSH from bastion and Ansible controller"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id, aws_security_group.ansible_controller.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = "${var.project_name}-bastion"

  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

module "ansible_controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = "${var.project_name}-ansible-controller"

  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ansible_controller.id]
  associate_public_ip_address = true

  root_block_device = {
    volume_size = 8
  }

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y python3-pip
    pip3 install ansible
  EOF

  tags = {
    Name = "${var.project_name}-ansible-controller"
  }
}

module "private_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  for_each = {
    "amazon-1" = { ami = var.ami_id, os = "amazon", subnet_idx = 0 }
    "amazon-2" = { ami = var.ami_id, os = "amazon", subnet_idx = 1 }
    "amazon-3" = { ami = var.ami_id, os = "amazon", subnet_idx = 0 }
    "ubuntu-1" = { ami = var.ubuntu_ami_id, os = "ubuntu", subnet_idx = 0 }
    "ubuntu-2" = { ami = var.ubuntu_ami_id, os = "ubuntu", subnet_idx = 0 }
    "ubuntu-3" = { ami = var.ubuntu_ami_id, os = "ubuntu", subnet_idx = 1 }
  }

  name = "${var.project_name}-${each.key}"

  ami                    = each.value.ami
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[each.value.subnet_idx]
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "${var.project_name}-${each.key}"
    OS   = each.value.os
  }
}
