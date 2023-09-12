output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "control_plane_security_group_id" {
  value = aws_security_group.control_plane_sg.id
}

output "data_plane_security_group_id" {
  value = aws_security_group.data_plane_sg.id
}

output "public_security_group_id" {
  value = aws_security_group.public_sg.id
}
