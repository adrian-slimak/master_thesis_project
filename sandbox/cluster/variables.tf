variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the selected region"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "project_name" {
  type    = string
  default = "mtp"
}

variable "cluster_name" {
  type    = string
  default = "mtp-k8s-cluster"
}

variable "s3_bucket_name" {
  type    = string
  default = "mtp-s3-bucket"
}
