# Security group for public subnet resources
resource "aws_security_group" "public_sg" {
  name   = "${var.project_name}-public-sg"
  vpc_id = aws_vpc.main.id

  # Ingress rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name                                        = "${var.project_name}-public-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
