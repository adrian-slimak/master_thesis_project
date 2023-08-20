variable "prefix" {
  description = "Prefix of the project"
  default     = "mtp"
}

# AWS

variable "aws_region" {
  description = "The Name of the AWS region"
  default     = "eu-central-1"
}

# EC2 Instances

variable "master_instance_type" {
  description = "Type of instance for master"
  default     = "t2.medium"
}

variable "master_subnet_id" {
  description = "The subnet-id to be used for the master instance. Master can be only in single subnet. All subnets have to belong to the same VPC."
  default = "subnet-03e2ca64c63a7d924"
}