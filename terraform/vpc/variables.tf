variable "project_name" {
  description = "The name of the project"
  default     = "mtp"
}

# AWS

variable "aws_region" {
  description = "The name of the AWS region"
  default     = "eu-central-1"
}

# VPC

variable "availability_zones" {
  description = "Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}