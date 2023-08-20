# Keypair

resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_keypair" {
  key_name   = "${var.prefix}_keypair"
  public_key = tls_private_key.cluster_key.public_key_openssh

  # Generate "key.pem" in current directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.cluster_key.private_key_pem}' > ./'${var.prefix}_key'.pem
      chmod 400 ./'${var.prefix}_key'.pem
    EOT
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

# Scripts

data "cloudinit_config" "master_cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init_kubernetes_master.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/scripts/init_kubernetes_master.sh", { cluster_name = "${var.prefix}_cluster" })
    # content      = templatefile("${path.module}/scripts/init_kubernetes_master.sh", { kubeadm_token = module.kubeadm-token.token, dns_name = "${var.cluster_name}.${var.hosted_zone}", ip_address = aws_eip.master.public_ip, cluster_name = var.cluster_name, addons = join(" ", var.addons), aws_region = var.aws_region, asg_name = "${var.cluster_name}-nodes", asg_min_nodes = var.min_worker_count, asg_max_nodes = var.max_worker_count, aws_subnets = join(" ", concat(var.worker_subnet_ids, [var.master_subnet_id])) } )
  }
}

# EC2 Instances - Master Nodes

# resource "aws_eip" "master_eip" {
#   vpc = true
# }

resource "aws_instance" "master_instance" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.cluster_keypair.key_name

  subnet_id = var.master_subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    # aws_default_security_group.default_sg.id
    "sg-0453a105765059a98"
  ]

  # iam_instance_profile = aws_iam_instance_profile.master_profile.name

  user_data = data.cloudinit_config.master_cloud_init.rendered

  tags = {
      "Name" = "${var.prefix}_cluster_master"
      # format("kubernetes.io/cluster/%v", var.prefix) = "owned"
    }

  # root_block_device {
  #   volume_type           = "gp2"
  #   volume_size           = "50"
  #   delete_on_termination = true
  # }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }
}

# resource "aws_eip_association" "master_eip_assoc" {
#   instance_id   = aws_instance.master_instance.id
#   allocation_id = aws_eip.master_eip.id
# }

# EC2 Instances - Worker Nodes
