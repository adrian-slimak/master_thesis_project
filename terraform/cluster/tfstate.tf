# Terraform state

terraform {
  backend "s3" {
    bucket = "mtp-s3-bucket"
    key    = "terraform/tf-cluster.tfstate"
    region = "eu-central-1"

    dynamodb_table = "mtp-state-locks"
    encrypt        = true
  }
}
