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

## How to run (updated for assignment 11):
### Build the amazon linux AMI with Packer:
  -  `cd` into your packer folder and run `packer init amazon-linux.pkr.hcl`, then `packer build amazon-linux.pkr.hcl`
  - when complete, you should see the artifacts of successful builds. You want to note the AMI id down.
  - <img width="1458" height="158" alt="image" src="https://github.com/user-attachments/assets/ee4a1c17-fba2-4c48-88b4-a6be17402357" />
  - <img width="1033" height="298" alt="image" src="https://github.com/user-attachments/assets/bca60b32-39ca-49da-851f-f20560e2c525" />

### Build the Ubunti AMI with Packer:
 - `cd packer`, then `packer build ubuntu.pkr.hcl`
   - your output should should the Ubuntu AMI ID. note this down.
     - <img width="1346" height="435" alt="image" src="https://github.com/user-attachments/assets/be5242e1-c903-49d3-8acf-ded2972db8e1" />

- Provision infrastructure with Terraform:
  - `cd` into your terraform folder and run `terraform init -upgrade`. You should see a success message when it's complete:
    - <img width="1453" height="557" alt="image" src="https://github.com/user-attachments/assets/ad27ecc4-9f2e-47fa-bb7c-bf37aeae6a0e" />
  - then, run `terraform plan`. It will ask for your ami id, ubuntu ami, and your public ip address. Enter those. It will then give you an overview of what Terraform will do:
    - <img width="1477" height="682" alt="image" src="https://github.com/user-attachments/assets/eba40b79-191b-462a-95a0-c5cf1272390d" />
  - If the plan looks good, run `terraform apply`. You will enter your AMI ID, Ubuntu AMI, and public ip again.
  - NOTE: if it fails due to instance shutting down, try running terraform apply again. The error is due to too many EC2 instances being created in one go (especially if using learner lab), and you'll need to run terraform apply a second time to create the remaining instances. There should be a total of 8 instances created from this.
    - <img width="1491" height="366" alt="image" src="https://github.com/user-attachments/assets/7f60cd48-753a-4769-80cc-8d31c2f515bc" />
    - Enter `yes` when asked to perform the actions, and you will get a success message along with outputs including your amazon linux private ips, ansible controller public ips, bastion public ip, and ubuntu private ips.        Note these down.
      - <img width="1472" height="533" alt="image" src="https://github.com/user-attachments/assets/44519f45-0a25-4733-b9fd-8c37ac2383b7" />

### Running the ansible playbook:
- go into the inventory.ini file and update the amazon linux and ubuntu IPS with the ones you got from the terraform apply output. I've added mine but you want to remove those and add yours instead'
  - <img width="1087" height="236" alt="image" src="https://github.com/user-attachments/assets/acc45a6f-050e-482b-90b4-ddc8a5922c0a" />
- copy your SSH key to the ansible controller. You can use the command `scp -i ~/.ssh/<your-private-key-name> ~/.ssh/<your-private-key> ec2-user@<ansible-controller-ip>:/home/ec2-user/.ssh/` if on MAC.
  - I did this step because the ansible controller will use my SSH private key to connect to the 6 private instances via SSH in order to perform the tasks I added to the playbook on those instances.
  - <img width="1451" height="68" alt="image" src="https://github.com/user-attachments/assets/d30c3184-94f2-4e2f-a66c-fdbd96ab8768" />
- copy the inventory.ini and playbook.yml to the ansible controller. `scp -i ~/.ssh/<your-private-key-name> ansible/inventory.ini ansible/playbook.yml ec2-user@<ansible-controller-ip>:~/`
  - <img width="1457" height="96" alt="image" src="https://github.com/user-attachments/assets/e70239fd-834c-4ee0-8789-a510a6bade0e" />
- SSH into the ansible controller. `ssh -i ~/.ssh/<your-private-key> ec2-user@<ansible-controller-ip>`
  - <img width="1386" height="396" alt="image" src="https://github.com/user-attachments/assets/7b6cfd61-55cf-4b3d-b054-70593cb5498a" />
- chmod 600 your key so that only you have permission to read/write the file: `chmod 600 ~/.ssh/<your-private-key>`
- verify Ansible is installed on the controller: `ansible --version`
- ssh into each ubuntu host and accept the host key. `ssh -i ~/.ssh/id_ed25519_hw8 ubuntu@<your-ubuntu-private-ip>`. Do this for all 3 of your ubuntu hosts.
- run the playbook: `ansible-playbook -i inventory.ini playbook.yml --private-key ~/.ssh/<your-private-key>`. Your output should show which playbook tasks were complete along with a recap at the end.
  - <img width="1915" height="930" alt="image" src="https://github.com/user-attachments/assets/4cc8602d-1c39-4c2c-a3b5-73c6f5380d0a" />
  - <img width="1908" height="932" alt="image" src="https://github.com/user-attachments/assets/19e8442b-9f4d-4d27-b92b-1c5813a8361d" />
  
## (FROM ASSIGNMENT 8) How to connect to the private instances from the bastion host:
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




