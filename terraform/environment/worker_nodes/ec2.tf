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
data "cloudinit_config" "worker_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "worker_userdata.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/worker_userdata.sh", {
      bucket_name = var.bucket_name
    })
  }
}

resource "aws_instance" "worker_instances" {
  count = var.worker_instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  key_name = var.keypair_name

  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [var.data_plane_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  # associate_public_ip_address = false

  user_data = data.cloudinit_config.worker_config.rendered

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name                                        = "${var.project_name}-k8s-worker-node-${count.index + 1}"
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
