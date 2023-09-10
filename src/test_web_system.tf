# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

##### Network resouces. #####
resource "aws_vpc" "iac-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "iac-vpc"
  }
}

resource "aws_internet_gateway" "iac-gateway" {
  vpc_id = aws_vpc.iac-vpc.id
  tags = {
    Name = "iac-gateway"
  }
}

resource "aws_route_table" "iac-route-table" {
  vpc_id = aws_vpc.iac-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iac-gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.iac-gateway.id
  }

  tags = {
    Name = "iac-route-table"
  }
}

resource "aws_subnet" "iac-subnet" {
  vpc_id            = aws_vpc.iac-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "iac-subnet"
  }
}

resource "aws_main_route_table_association" "iac-association" {
  vpc_id         = aws_vpc.iac-vpc.id
  route_table_id = aws_route_table.iac-route-table.id
}

resource "aws_security_group" "iac-security-group" {
  name        = "iac-security-group"
  description = "created by terraform. Allow trrafic for web app."
  vpc_id      = aws_vpc.iac-vpc.id

  ingress {
    description = "https access allow from anywhere."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http access allow from anywhere."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh access allow from anywhere."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0             # all port
    to_port          = 0             # all port
    protocol         = "-1"          # all protocol
    cidr_blocks      = ["0.0.0.0/0"] # all ip address
    ipv6_cidr_blocks = ["::/0"]      # all ip address
  }

  tags = {
    Name = "iac-security_-group"
  }
}

resource "aws_network_interface" "iac-nw-interface" {
  subnet_id       = aws_subnet.iac-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.iac-security-group.id]
  tags = {
    Name = "iac-nw-interface"
  }
}



##### EC2 resouces. #####
resource "aws_instance" "iac-instance" {
  ami               = "ami-0a21e01face015dd9" # Amazon linux2023
  instance_type     = "t2.micro"              # for free.
  availability_zone = "ap-northeast-1a"
  key_name          = "aws-kensho"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.iac-nw-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo bash -c 'echo terraform practice! > /var/www/html/index.html' 
              EOF
  tags = {
    Name = "iac-instance"
  }
}

resource "aws_eip" "iac-eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.iac-nw-interface.id
  depends_on = [
    aws_internet_gateway.iac-gateway,
    aws_instance.iac-instance
  ]
  tags = {
    Name = "iac-eip"
  }
}

resource "aws_eip_association" "eip_associate" {
  instance_id   = aws_instance.iac-instance.id
  allocation_id = aws_eip.iac-eip.id
}
