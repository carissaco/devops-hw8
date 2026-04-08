packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519_hw8.pub"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  ami_name      = "hw11-ubuntu-docker-{{timestamp}}"
  instance_type = "t2.micro"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-amd64/ubuntu-*-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # Install Docker
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  # Inject SSH public key
  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "echo '${file(var.ssh_public_key_path)}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]
  }
}
