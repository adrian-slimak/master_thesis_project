variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "data_plane_security_group_id" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "worker_instance_count" {
  type    = number
  default = 1
}

variable "bucket_name" {
  type = string
}

variable "keypair_name" {
  type = string
}
