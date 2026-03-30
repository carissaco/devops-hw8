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
- Your IP address
- AWS CLI installed and configured with credentials
- an SSH key pair
- an AWS account with acces to us-east-1

### How to run:
- Build the AMI with Packer: `cd` into your packer folder and run `packer init .`, then `packer build amazon-linux.pkr.hcl`
  - when complete, you should see the artifacts of successful builds. You want to note the AMI id down.
  - <img width="1458" height="158" alt="image" src="https://github.com/user-attachments/assets/ee4a1c17-fba2-4c48-88b4-a6be17402357" />
  - <img width="1033" height="298" alt="image" src="https://github.com/user-attachments/assets/bca60b32-39ca-49da-851f-f20560e2c525" />
- Provision infrastructure with Terraform:
  - `cd` into your terraform folder and run `terraform init`. You should see a success message when it's complete:
    - <img width="1453" height="557" alt="image" src="https://github.com/user-attachments/assets/ad27ecc4-9f2e-47fa-bb7c-bf37aeae6a0e" />
  - then, run `terraform plan`. It will ask for your ami id and your public ip address. Enter those. It will then give you an overview of what Terraform will do:
    - <img width="1477" height="682" alt="image" src="https://github.com/user-attachments/assets/eba40b79-191b-462a-95a0-c5cf1272390d" />
  - If the plan looks good, run `terraform apply`. You will enter your AMI ID and public ip again.
    - <img width="1487" height="632" alt="image" src="https://github.com/user-attachments/assets/2a5297c0-6659-435b-89cc-1b9433cf2046" />
    - Enter `yes` when asked to perform the actions, and you will get a success message along with outputs including your bastion public ip, and private instance ips
      - <img width="1481" height="510" alt="image" src="https://github.com/user-attachments/assets/ba326789-49ae-4a6c-8dad-76de5f40a423" />
      








## How to connect to the private instances from the bastion host:
