provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = "${var.project_name}-vpc"
    Project                                     = var.project_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Create the private subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name                                        = "${var.project_name}-private-subnet-${regex("-(\\d+[a-z])$", element(var.availability_zones, count.index))[0]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

# Create the public subnets
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name                                        = "${var.project_name}-public-subnet-${regex("-(\\d+[a-z])$", element(var.availability_zones, count.index))[0]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = 1
  }

  # map_public_ip_on_launch = true
}

# Add Name tag to default route table
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.project_name}-default-route-table"
  }
}

# Add Name tag to default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-default-security-group"
  }
}
