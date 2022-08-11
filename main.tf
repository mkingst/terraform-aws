provider "aws" {
  region = lookup(var.awsprops, "region")
}

data "aws_ami" "buster" {
  most_recent = true
  owners = ["aws-marketplace"]

  filter {
    name = "name"
    values = ["debian-10-amd64-*"]
   }
  }

resource "aws_key_pair" "deployer" {
    key_name   = "deployer"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "nginx-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 90
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 11080
    protocol = "tcp"
    to_port = 11085
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8000
    protocol = "tcp"
    to_port = 8100
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "project-iac" {
  ami = data.aws_ami.buster.id
  instance_type = lookup(var.awsprops, "itype")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [
    aws_security_group.nginx-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
  }
  tags = {
    Name ="NGINX Plus"
    Environment = "DEV"
    OS = "UBUNTU"
    ManagedBy = "m.kingston@f5.com"
  }

  depends_on = [ aws_security_group.nginx-iac-sg ]
}

output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
