provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc_for_k8s" {
  source = "./vpc"

  project_name       = var.project_name
  cluster_name       = var.cluster_name
  aws_region         = var.aws_region
  availability_zones = var.availability_zones
}

# Keypair
module "keypair_for_k8s" {
  source = "./keypair"

  keypair_name  = "${var.project_name}-k8s-keypair"
  key_file_name = "${var.project_name}-ssh-key.pem"
  bucket_name   = "${var.project_name}-s3-bucket"
}

# Upload rke_config.yml to s3 bucket
resource "aws_s3_object" "rke_config_object" {
  bucket = "${var.project_name}-s3-bucket"
  key    = "cluster.yml"

  content = templatefile("${path.root}/rke_cluster.yml", {
    cluster_name = var.cluster_name
  })
}

# K8s Bastion Host
module "bastion_host_for_k8s" {
  source = "./bastion_host"

  depends_on = [
    module.vpc_for_k8s,
    module.keypair_for_k8s,
    module.master_nodes_for_k8s,
    module.worker_nodes_for_k8s
  ]

  project_name = var.project_name
  cluster_name = var.cluster_name

  vpc_id                   = module.vpc_for_k8s.vpc_id
  public_subnet_ids        = module.vpc_for_k8s.public_subnet_ids
  public_security_group_id = module.vpc_for_k8s.public_security_group_id

  keypair_name = module.keypair_for_k8s.keypair_name
  key_name     = "${var.project_name}-ssh-key.pem"
  bucket_name  = var.s3_bucket_name
}

# K8s Cluster Master Node
module "master_nodes_for_k8s" {
  source = "./master_nodes"

  depends_on = [
    module.vpc_for_k8s,
    module.keypair_for_k8s
  ]

  project_name = var.project_name
  cluster_name = var.cluster_name

  vpc_id                          = module.vpc_for_k8s.vpc_id
  private_subnet_ids              = module.vpc_for_k8s.public_subnet_ids
  control_plane_security_group_id = module.vpc_for_k8s.control_plane_security_group_id

  keypair_name = module.keypair_for_k8s.keypair_name
  bucket_name  = var.s3_bucket_name
}

# K8s Cluster Worker Nodes
module "worker_nodes_for_k8s" {
  source = "./worker_nodes"

  depends_on = [
    module.vpc_for_k8s,
    module.keypair_for_k8s
  ]

  project_name = var.project_name
  cluster_name = var.cluster_name

  vpc_id                       = module.vpc_for_k8s.vpc_id
  private_subnet_ids           = module.vpc_for_k8s.public_subnet_ids
  data_plane_security_group_id = module.vpc_for_k8s.data_plane_security_group_id

  keypair_name = module.keypair_for_k8s.keypair_name
  bucket_name  = var.s3_bucket_name
}
