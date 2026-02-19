provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "healthcare_sg" {
  name = "healthcare_sg"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "healthcare_ec2" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
  key_name      = "healthcare-key"

  vpc_security_group_ids = [aws_security_group.healthcare_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker git -y
              systemctl start docker
              systemctl enable docker
              git clone https://github.com/aayushpatidar30/Healthcare-DevOps-Docker.git
              cd Healthcare-DevOps-Docker
              docker build -t healthcare-app .
              docker run -d -p 5000:5000 healthcare-app
              EOF

  tags = {
    Name = "Healthcare-App-Terraform"
  }
}
