resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH only from my IP"
  vpc_id      = var.vpc_id

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

resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-grafana-sg"
  description = "Allow SSH from bastion and port 3000 from bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-grafana-sg"
  }
}

resource "aws_security_group" "prometheus" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Allow SSH from bastion and port 9090 from grafana and bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana.id, aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-prometheus-sg"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "Allow SSH from bastion and node exporter from prometheus"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id]
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

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_instance" "private" {
  count                  = 6
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}

resource "aws_instance" "prometheus" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.prometheus.id]

  tags = {
    Name = "${var.project_name}-prometheus"
  }
}

resource "aws_instance" "grafana" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.grafana.id]

  tags = {
    Name = "${var.project_name}-grafana"
  }
}
