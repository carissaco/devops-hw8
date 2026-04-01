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
  ami_name      = "hw9-amazon-linux-{{timestamp}}"
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

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
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

  # Install Prometheus
  provisioner "shell" {
    inline = [
      "curl -LO https://github.com/prometheus/prometheus/releases/download/v2.53.0/prometheus-2.53.0.linux-amd64.tar.gz",
      "tar -xzf prometheus-2.53.0.linux-amd64.tar.gz",
      "sudo mv prometheus-2.53.0.linux-amd64/prometheus /usr/local/bin/",
      "sudo mv prometheus-2.53.0.linux-amd64/promtool /usr/local/bin/",
      "sudo mkdir -p /etc/prometheus /var/lib/prometheus",
      "sudo cp -r prometheus-2.53.0.linux-amd64/consoles /etc/prometheus",
      "sudo cp -r prometheus-2.53.0.linux-amd64/console_libraries /etc/prometheus",
      "rm -rf prometheus-2.53.0.linux-amd64*",
      "sudo useradd -rs /bin/false prometheus",
      "sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool",
      "sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus",
      "sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF\n[Unit]\nDescription=Prometheus\nAfter=network.target\n\n[Service]\nUser=prometheus\nExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl daemon-reload"
    ]
  }

  # Install Grafana
  provisioner "shell" {
    inline = [
      "sudo bash -c 'cat > /etc/yum.repos.d/grafana.repo <<EOF\n[grafana]\nname=grafana\nbaseurl=https://rpm.grafana.com\nrepo_gpgcheck=1\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.grafana.com/gpg.key\nsslverify=1\nsslcacert=/etc/pki/tls/certs/ca-bundle.crt\nEOF'",
      "sudo dnf install -y grafana",
      "sudo systemctl daemon-reload"
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
