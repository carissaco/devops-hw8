provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

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

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  ami_id             = var.ami_id
  my_ip              = var.my_ip
  public_subnet_id   = module.vpc.public_subnets[0]
  private_subnet_ids = module.vpc.private_subnets
}
