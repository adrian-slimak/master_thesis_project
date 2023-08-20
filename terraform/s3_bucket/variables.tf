variable "aws_region" {
  type        = string
  description = "The Name of the AWS region"
  default     = "eu-central-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of the Bucket"
  default     = "mtp-s3-bucket"
}

variable "state_locks_name" {
  type        = string
  description = "The name of the state locks DynamoDB table"
  default     = "mtp-state-locks"
}
