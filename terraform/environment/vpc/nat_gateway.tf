# Create NAT Gateway for the private subnets
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.natgw.id
#   subnet_id     = aws_subnet.public_subnets[0].id

#   tags = {
#     Name                                        = "${var.project_name}-natgw"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }

# Create Elastic IP for NAT Gateway
# resource "aws_eip" "natgw" {

#   tags = {
#     Name = "${var.project_name}-natgw-eip"
#   }
# }

# Create custom route table and route private subnets traffic through the NAT
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }

#   tags = {
#     Name                                        = "${var.project_name}-private-rt"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }

# Custom route table and private subnets associations
# resource "aws_route_table_association" "private_subnets_internet_access" {
#   count          = length(var.availability_zones)
#   subnet_id      = aws_subnet.private_subnets[count.index].id
#   route_table_id = aws_route_table.private_rt.id
# }
