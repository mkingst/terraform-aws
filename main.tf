provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "tls_private_key" "pk" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

resource "aws_key_pair" "deployer" {
    key_name   = "deployer"
    public_key = tls_private_key.pk.public_key_openssh

    provisioner "local-exec" {
      command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
    }
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
    to_port = 80
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
  ami = lookup(var.awsprops, "ami")
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
