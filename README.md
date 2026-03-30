## Description:
- In this repo, I used Packer to create a custom AMI and Terraform to create infrastructure that uses that AMI.
- The AMI includes Amazon Linux, Docker, and my SSH public key pre-installed.
- Terraform provisions a VPC with public and private subnets, a bastion host in the public subnet, and 6 EC2 instances in the private subnet using the custom AMI.

## Repository Structure
```
hw8/
├── packer/
│   └── amazon-linux.pkr.hcl       # Packer template that builds the custom AMI.
│                                  # Installs Docker and injects the SSH public key.
├── terraform/
│   ├── main.tf                    # Root module that wires the vpc and ec2 modules together.
│   ├── variables.tf               # Input variables: AMI ID, your IP, region, project name.
│   ├── outputs.tf                 # Outputs the bastion public IP and private instance IPs after apply.
│   └── modules/
│       ├── vpc/
│       │   ├── main.tf            # Creates the VPC, public/private subnets, internet gateway,
│       │   │                      # NAT gateway, route tables, and route table associations.
│       │   ├── variables.tf       # Input variables for the VPC module.
│       │   └── outputs.tf         # Outputs the VPC ID and subnet IDs.
│       └── ec2/
│           ├── main.tf            # Creates the bastion host, 6 private EC2 instances,
│           │                      # and security groups restricting SSH access.
│           ├── variables.tf       # Input variables for the EC2 module.
│           └── outputs.tf         # Outputs the bastion public IP and private instance IPs.
└── README.md
```


## Instructions to run the project

### Prerequisites needed before running the project:
- Packer installed
- Terraform installed
- AWS CLI installed and configured with credentials
- an SSH key pair
- an AWS account with acces to us-east-1

### How to run:
- Build the AMI with Packer: cd into your packer folder and run packer init, then packer build amazon-linux.pkr.hcl



## How to connect to the private instances from the bastion host: