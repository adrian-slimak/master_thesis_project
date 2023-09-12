# Security group for control plane
resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project_name}-k8s-control-plane-sg"
  vpc_id = aws_vpc.main.id

  # Ingress rules
  ingress {
    description     = "Allow inbound SSH"
    from_port       = 0
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  ingress {
    description = "Allow inbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
  }

  ingress {
    description     = "Allow inbound 443"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  ingress {
    description     = "Allow inbound 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Egress rules
  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.project_name}-k8s-control-plane-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
