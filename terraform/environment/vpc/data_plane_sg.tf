# Security group for data plane
resource "aws_security_group" "data_plane_sg" {
  name   = "${var.project_name}-k8s-data-plane-sg"
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
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
  }

  ingress {
    description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = flatten([var.private_subnet_cidr_blocks])
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
    Name                                        = "${var.project_name}-k8s-data-plane-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
