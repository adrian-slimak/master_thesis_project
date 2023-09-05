# VPC

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_security_group" "sg" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_name]
  }
}

data "aws_subnet" "master_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  
  filter {
    name = "tag:Name"
    values = [var.master_subnet_name]
  }
}

data "aws_subnet" "worker_subnets" {
  for_each = toset(var.worker_subnet_names)
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  
  filter {
    name = "tag:Name"
    values = [each.key]
  }
}

# output "master_subnet_id" {
  # value = data.aws_subnet.master_subnet.id
# }

# output "worker_subnet_ids" {
  # value = { for subnet_name, subnet in data.aws_subnet.worker_subnets : subnet_name => subnet.id }
# }

# Keypair

resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_keypair" {
  key_name   = "${var.project_name}_keypair"
  public_key = tls_private_key.cluster_key.public_key_openssh

  # generate "key.pem" in current directory
  provisioner "local-exec" {
    # interpreter = ["powershell", "-Command"]
    command = <<-eot
      echo '${tls_private_key.cluster_key.private_key_pem}' > ./'${var.project_name}_key'.pem
      chmod 400 ./'${var.project_name}_key'.pem
    eot
  }
}

# AWS AMI

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

# Generate kubeadm token

module "kubeadm-token" {
  source = "scholzj/kubeadm-token/random"
}

# Scripts

data "cloudinit_config" "master_cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init_kubernetes_master.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/scripts/init_kubernetes_master.sh", {
      cluster_name = "${var.project_name}_cluster",
      dns_name = "${var.project_name}.${var.aws_region}",
      ip_address = aws_eip.master_eip.public_ip,
      kubeadm_token = module.kubeadm-token.token
    })
    # content      = templatefile("${path.module}/scripts/init_kubernetes_master.sh", { kubeadm_token = module.kubeadm-token.token, dns_name = "${var.cluster_name}.${var.hosted_zone}", ip_address = aws_eip.master.public_ip, cluster_name = var.cluster_name, addons = join(" ", var.addons), aws_region = var.aws_region, asg_name = "${var.cluster_name}-nodes", asg_min_nodes = var.min_worker_count, asg_max_nodes = var.max_worker_count, aws_subnets = join(" ", concat(var.worker_subnet_ids, [var.master_subnet_id])) } )
  }
}

# EC2 Instances - Master Nodes

resource "aws_eip" "master_eip" {
}

resource "aws_instance" "master_instance" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.master_instance_type

  key_name = aws_key_pair.cluster_keypair.key_name

  subnet_id = data.aws_subnet.master_subnet.id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    data.aws_security_group.sg.id
  ]

  # iam_instance_profile = aws_iam_instance_profile.master_profile.name

  user_data = data.cloudinit_config.master_cloud_init.rendered

  tags = {
      "Name" = "${var.project_name}_cluster_master"
      # format("kubernetes.io/cluster/%v", var.project_name) = "owned"
    }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }
}

resource "aws_eip_association" "master_eip_assoc" {
  instance_id   = aws_instance.master_instance.id
  allocation_id = aws_eip.master_eip.id
}

output "master_instance_public_ip" {
  value = ["${aws_eip.master_eip.public_ip}"]
}

# EC2 Instances - Worker Nodes

# resource "aws_instance" "worker_instances" {
  # count = var.worker_count

  # ami = data.aws_ami.amazon_linux.id
  # instance_type = var.worker_instance_type

  # key_name = aws_key_pair.cluster_keypair.key_name

  # subnet_id = data.worker_subnets[count.index % length(data.worker_subnets)]
  # associate_public_ip_address = true

  # vpc_security_group_ids = [
    # var.kubernetes_sg_id
  # ]

  # # iam_instance_profile = aws_iam_instance_profile.master_profile.name

  # user_data = data.cloudinit_config.master_cloud_init.rendered

  # tags = {
      # "Name" = "${var.project_name}_cluster_worker_${count.index + 1}"
    # }

  # lifecycle {
    # ignore_changes = [
      # ami,
      # user_data,
      # associate_public_ip_address
    # ]
  # }
# }
