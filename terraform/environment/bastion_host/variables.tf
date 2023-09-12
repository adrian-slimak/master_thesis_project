variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "public_security_group_id" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bucket_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "key_name" {
  type = string
}
