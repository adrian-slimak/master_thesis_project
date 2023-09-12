# Find AWS AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create cloudinit config file
data "cloudinit_config" "bastion_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bastion_userdata.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/bastion_userdata.sh", {
      bucket_name  = var.bucket_name,
      ssh_key_name = var.key_name
    })
  }
}

# Create bastion host ec2 instance
resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  key_name = var.keypair_name

  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.public_security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = false

  user_data = data.cloudinit_config.bastion_config.rendered

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name                                        = "${var.project_name}-bastion-host"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }
}

# Create elastic ip for bastion host
resource "aws_eip" "bastion_host_eip" {

  tags = {
    Name = "${var.project_name}-bastion-host-eip"
  }
}

resource "aws_eip_association" "bastion_host_eip_association" {
  instance_id   = aws_instance.bastion_host.id
  allocation_id = aws_eip.bastion_host_eip.id
}
