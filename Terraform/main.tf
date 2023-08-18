
# AWS Provider

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# Terraform state

terraform {
 backend "s3" {
  bucket         = "mtp-terraform-state-s3"
  key            = "global/s3/terraform.tfstate"
  region         = "eu-central-1"

  # Replace this with your DynamoDB table name!
  #dynamodb_table = "terraform-up-and-running-locks"
  encrypt        = true
 }
}

# VPC

# Create a VPC
resource "aws_vpc" "vpc" {
 cidr_block = "10.0.0.0/16"

 tags = {
  Name = "mtp_vpc"
 }
}

resource "aws_internet_gateway" "gateway" {
 vpc_id = aws_vpc.vpc.id

 tags = {
  Name = "mtp_gateway"
 }
}

resource "aws_default_route_table" "default_route_table" {
 default_route_table_id = aws_vpc.vpc.default_route_table_id

 tags = {
    Name = "mtp_default_route_table"
 }
}

resource "aws_route_table" "public_route_table" {
 vpc_id = aws_vpc.vpc.id

 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gateway.id
 }

 tags = {
  Name = "mtp_public_route_table"
 }
}

resource "aws_subnet" "private_subnets" {
 count = length(var.private_subnet_cidrs)
 vpc_id = aws_vpc.vpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
  Name = "mtp_private_subnet_${count.index + 1}"
 }
}

resource "aws_subnet" "public_subnets" {
 count = length(var.public_subnet_cidrs)
 vpc_id = aws_vpc.vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
  Name = "mtp_public_subnet_${count.index + 1}"
 }
}

resource "aws_route_table_association" "public_subnet_association" {
 count = length(var.public_subnet_cidrs)
 subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_route_table.id
}

resource "aws_default_security_group" "default_security_group" {
 vpc_id = aws_vpc.vpc.id
 
 ingress {
  description = "Allow SSH access"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 ingress {
  description = "Allow internal cluster communication"
  from_port = 0
  to_port = 0
  protocol = "-1"
  self = true
 }
 
 ingress {
  description = "Kubernetes API Server"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  self = true
 }
 
 #ingress {
 # description = "Pod-to-Pod Communication"
 # from_port = 0
 # to_port = 65535
 # protocol = "tcp"
 # self = true
 #}

 egress {
  description = "Allow outgoing traffic"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "mtp_default_security_group"
 }
}

# AWS ami

data "aws_ami" "amazon_linux" {
 most_recent = true
 owners = ["amazon"]
 
 filter {
  name = "name"
  values = ["al2023-ami-*"]
 }
 
 filter {
  name = "architecture"
  values = ["x86_64"]
 }
 
 filter {
  name = "virtualization-type"
  values = ["hvm"]
 }
}
