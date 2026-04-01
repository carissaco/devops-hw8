## Description (with Assignment 9 updates):
- In this repo, I used Packer to create a custom AMI and Terraform to create infrastructure that uses that AMI.
- The AMI includes Amazon Linux, Docker, and my SSH public key pre-installed.
- Terraform provisions a VPC with public and private subnets, a bastion host in the public subnet, and 6 EC2 instances in the private subnet using the custom AMI.
- - Prometheus and Grafana are deployed as EC2 instances in the private subnet for monitoring.
-  The AMI includes Node Exporter, which exposes system metrics (CPU, memory, disk) on port 9100 so Prometheus can
  scrape them.
- Prometheus is configured to scrape Node Exporter on all 6 private instances every 15 seconds.
- Grafana is connected to Prometheus as a datasource and can be used to visualize the metrics.

## Repository Structure
```
  hw8/
  ├── packer/
  │   └── amazon-linux.pkr.hcl      # Packer template that builds the custom AMI.
  │                                  # Installs Docker, Node Exporter, Prometheus, and Grafana.
  │                                  # Injects SSH public key.
  ├── terraform/
  │   ├── main.tf                    # Root module that wires the vpc and ec2 modules together.
  │   ├── variables.tf               # Input variables: AMI ID, your IP, region, project name.
  │   ├── outputs.tf                 # Outputs bastion IP, private IPs, Prometheus IP, Grafana IP.
  │   └── modules/
  │       ├── vpc/
  │       │   ├── main.tf            # Creates the VPC, public/private subnets, internet gateway,
  │       │   │                      # NAT gateway, route tables, and route table associations.
  │       │   ├── variables.tf       # Input variables for the VPC module.
  │       │   └── outputs.tf         # Outputs the VPC ID and subnet IDs.
  │       └── ec2/
  │           ├── main.tf            # Creates the bastion, 6 private instances, Prometheus instance,
  │           │                      # Grafana instance, and security groups.
  │           ├── variables.tf       # Input variables for the EC2 module.
  │           └── outputs.tf         # Outputs bastion IP, private IPs, Prometheus IP, Grafana IP.
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
    - Enter `yes` when asked to perform the actions, and you will get a success message along with outputs including your bastion public ip, grafana private ip, prometheus private ip, and private instance ips
      - <img width="1246" height="397" alt="image" src="https://github.com/user-attachments/assets/dff1f5e4-327a-4658-9c33-c132c26871ac" />


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

## Connecting to Prometheus and Grafana:

### Prometheus:
- ssh into bastion using your bastion public ip using -A for agent forwarding, the go to the Prometheus instance using the prometheus_private_ip from the terraform output:
  ```
  ssh -A -i ~/.ssh/id_ed25519_hw8 ec2-user@<bastion-public-ip>
  ssh ec2-user@<prometheus_private_ip>
  ```
  - <img width="1237" height="741" alt="image" src="https://github.com/user-attachments/assets/f4e246c9-648b-48fd-9316-846a30809de6" />
-  Configure Prometheus by editing the config file with sudo vi /etc/prometheus/prometheus.yml and adding the private instance IPs from the terraform
  output
  - <img width="1837" height="166" alt="image" src="https://github.com/user-attachments/assets/1f107e1d-5bc4-4339-a355-2eb68ccec66f" />
- start prometheus using `sudo systemctl start prometheus`
- Run `sudo systemctl status prometheus` to check if it's running
  - <img width="1888" height="488" alt="image" src="https://github.com/user-attachments/assets/c794eab9-2287-4d44-a45b-06e6e2073f35" />

### Grafana:
- From the bastion, hop to the Grafana instance `ssh ec2-user@<grafana_private_ip>`
- start grafana `sudo systemctl start grafana-server`
- run `sudo systemctl status grafana-server` to check that it's running
  - <img width="1910" height="483" alt="image" src="https://github.com/user-attachments/assets/b6ca8a65-cd38-4f4b-a09b-59910aceb348" />
- Open your browser at http://localhost:3000 and log in. Reset the admin password if needed using `sudo grafana-cli admin reset-admin-password admin`
  - <img width="1919" height="988" alt="grafana browser login" src="https://github.com/user-attachments/assets/47dcfe92-a267-45c8-9831-92b8857e1168" />
  - <img width="1919" height="981" alt="in grafana dashboard" src="https://github.com/user-attachments/assets/8346faf3-2c33-495a-b036-054150d05ac5" />
- Go to Connections → Data sources → Add data source, select Prometheus, and set the URL to http://<prometheus_private_ip>:9090. Click save and test
  - <img width="1919" height="920" alt="add prometheus as a datasource" src="https://github.com/user-attachments/assets/1944b0b4-7961-4936-a309-0ea32c218148" />
    - when you get the success message, that means it's working
      - <img width="1565" height="160" alt="prometheus datasource working" src="https://github.com/user-attachments/assets/a651a8e6-1a56-45bc-b16c-3f2c7436efe6" />
- Go to explore -> prometheus and run the query `node_cpu_seconds_total`. This will allow you to see  the metrics data from the private instances
  - <img width="1628" height="932" alt="image" src="https://github.com/user-attachments/assets/7eb1a66b-f27a-4445-babb-79fda1471f3e" />



  

  

  

- SSH from bastion into the Grafana instance 




