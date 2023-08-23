variable "project_name" {
  description = "The name of the project"
  default     = "mtp"
}

# AWS

variable "aws_region" {
  description = "The Name of the AWS region"
  default     = "eu-central-1"
}

# EC2 Instances

variable "vpc_name" {
  description = "The name of the vpc to be used for the cluster."
  default = "mtp-vpc"
}

variable "security_group_name" {
  description = "The name of the security group to be used for the cluster."
  default = "mtp-kubernetes-sg"
}

variable "master_instance_type" {
  description = "Type of instance for master"
  default     = "t2.micro"
}

variable "master_subnet_name" {
  description = "The subnet name to be used for the master instance."
  default = "mtp-public-subnet-1"
}

variable "worker_instance_type" {
  description = "Type of instance for master"
  default     = "t2.micro"
}

variable "worker_subnet_names" {
  description = "The subnet names to be used for the worker instances."
  default = ["mtp-public-subnet-1", "mtp-public-subnet-2", "mtp-public-subnet-3"]
}

variable "worker_count" {
  description = "The number of workers"
  default = 0
}

variable "kubernetes_sg_id" {
  description = "The security-group-id to be used for the master instance."
  default = "sg-006a6dea43144861a"
}
