
# VPC

variable "aws_region" {
 type = string
 description = "AWS Region"
 default = "eu-central-1"
}

variable "bucket_name" {
 type = string
 description = "Bucket name"
 default = "mtp-terraform-state-s3"
}