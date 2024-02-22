provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc" {
  source = "./vpc"

  aws_region         = var.aws_region
  availability_zones = var.availability_zones
  project_name       = var.project_name
  cluster_name       = var.cluster_name
}

# Instances

data "cloudinit_config" "master_config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init_master.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/init_master.sh")
  }
}

resource "aws_instance" "master" {
  ami                  = "ami-0faab6bdbac9486fb"
  instance_type        = "t3.medium"
  user_data            = data.cloudinit_config.master_config.rendered
  iam_instance_profile = aws_iam_instance_profile.node.name

  key_name = "key1"

  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.public_security_group_id]
  associate_public_ip_address = true

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = "15"
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name                                        = "${var.project_name}-master"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

data "cloudinit_config" "worker_config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init_worker.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/init_worker.sh")
  }
}

resource "aws_instance" "worker" {
  count = 2
  ami                  = "ami-0faab6bdbac9486fb"
  instance_type        = "t3.medium"
  user_data            = data.cloudinit_config.worker_config.rendered
  iam_instance_profile = aws_iam_instance_profile.node.name

  key_name = "key1"

  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.public_security_group_id]
  associate_public_ip_address = true

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = "15"
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name                                        = "${var.project_name}-worker-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}
