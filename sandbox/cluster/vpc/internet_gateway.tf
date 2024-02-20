# Create IGW for the public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                        = "${var.project_name}-internet-gateway"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Create custom route table and route public subnets traffic through the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name                                        = "${var.project_name}-public-route-table"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Custom route table and public subnets associations
resource "aws_route_table_association" "public_subnets_internet_access" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
