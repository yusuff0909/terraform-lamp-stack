# configured aws provider with proper credentials
provider "aws" {
  region    = var.aws_region
  profile   = "default"
}
# Create a VPC
resource "aws_vpc" "lamp-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Lamp VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "lamp-subnet" {
  vpc_id                  = aws_vpc.lamp-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "lamp-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lamp-vpc.id

  tags = {
    Name = "Lamp IGW"
  }
}

# Create Web layer route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.lamp-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lamp WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lamp-subnet.id
  route_table_id = aws_route_table.web-rt.id
 }

# Create Web Security Group
resource "aws_security_group" "lamp-sg" {
    name        = "Lamp security group"
    description = "Allow ssh inbound traffic"
    vpc_id      = aws_vpc.lamp-vpc.id
  
    ingress {
      description = "ssh from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "Lamp-SG"
    }
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#create ec2 instance for Lamp stack

resource "aws_instance" "lamp_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.lamp-subnet.id
  vpc_security_group_ids = [aws_security_group.lamp-sg.id]
  key_name               = aws_key_pair.lamp_key.key_name
  user_data              = file("install_lamp.sh")
   
  tags = {
    owner   = "Lamp-estephe"
    Environment = "dev"
    Name  = "lamp stack"
  }
}
# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.lamp_server.public_ip
  }
  # wait for ec2 to be created
  depends_on = [aws_instance.lamp_server]
}