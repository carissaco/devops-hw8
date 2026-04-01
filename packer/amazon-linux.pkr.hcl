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

source "amazon-ebs" "amazon_linux" {
  region        = var.aws_region
  ami_name      = "hw9-amazon-linux-docker-node-exporter-{{timestamp}}"
  instance_type = "t2.micro"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.amazon_linux"]

  # Install Docker
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user"
    ]
  }

  # Install Node Exporter
  provisioner "shell" {
    inline = [
      "curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz",
      "tar -xzf node_exporter-1.8.2.linux-amd64.tar.gz",
      "sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/",
      "rm -rf node_exporter-1.8.2.linux-amd64*",
      "sudo useradd -rs /bin/false node_exporter",
      "sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=node_exporter\nExecStart=/usr/local/bin/node_exporter\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable node_exporter",
      "sudo systemctl start node_exporter"
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
