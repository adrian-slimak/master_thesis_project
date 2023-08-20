# Terraform state

terraform {
  backend "s3" {
    bucket = "mtp-s3-bucket"
    key    = "terraform/tf-vpc.tfstate"
    region = "eu-central-1"

    dynamodb_table = "mtp-state-locks"
    encrypt        = true
  }
}
