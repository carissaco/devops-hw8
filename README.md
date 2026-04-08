## Description:
- In this repo, I used Packer to create a custom AMI and Terraform to create infrastructure that uses that AMI.
- The AMI includes Amazon Linux, Docker, and my SSH public key pre-installed.
- Terraform provisions a VPC with public and private subnets, a bastion host in the public subnet, and 6 EC2 instances in the private subnet using the custom AMI.

## Repository Structure
```
● devops-hw8/
  ├── README.md                    
  ├── .gitignore                   
  ├── packer/                       # Packer templates for building custom AMIs
  │   ├── amazon-linux.pkr.hcl      # Amazon Linux 2023 AMI with Docker
  │   └── ubuntu.pkr.hcl            # Ubuntu 24.04 AMI with Docker
  ├── terraform/                    # Terraform scripts to provision AWS resources
  │   ├── main.tf                   # VPC, EC2 instances, security groups. Using both modules and handwritten resources for easier tasks
  │   ├── variables.tf              # Input variables (AMI IDs, IP, region)
  │   └── outputs.tf                # Output values (instance IPs)
  └── ansible/                       # Ansible configuration management
      ├── playbook.yml               # Playbook instructions to run 
      └── inventory.ini              # Host inventory for the 6 EC2 instances so they know which hosts to connect to
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
- Build the AMI with Packer: `cd` into your packer folder and run `packer init amazon-linux.pkr.hcl`, then `packer build amazon-linux.pkr.hcl`
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
- ssh into bastion using your bastion public ip using -A for agent forwarding:
  ```
  ssh -A -i ~/.ssh/id_ed25519_hw8 ec2-user@<bastion-public-ip>
  ```
  - <img width="1470" height="275" alt="image" src="https://github.com/user-attachments/assets/6667b26a-0881-4936-b704-5a9e8f39c62b" />
- then connect to one of the private instances by doing ssh using one of the private instance ips:
  ```
  ssh ec2-user@<private-instance-ip>
  ```
  - <img width="1461" height="252" alt="image" src="https://github.com/user-attachments/assets/a6ddd90e-e961-4de5-9153-2ab0b6ec6ee1" />
- finally, verify that docker is working on the private instance by running `docker --version`
  - <img width="1482" height="51" alt="image" src="https://github.com/user-attachments/assets/d5880d52-5a72-42f2-ab9d-a0302c0958a9" />


  # FOR ASSIGNMENT 11:
  ## Build the Ubunti AMI with Packer:
  - `cd packer`, then `packer build ubuntu.pkr.hcl`
    - your output should should the Ubuntu AMI ID. note this down.




