# Save terraform state in s3 bucket

terraform {
  backend "s3" {
    bucket = "mtp-s3-bucket"
    key    = "terraform/mpt-k8s-cluster.tfstate"
    region = "eu-central-1"

    dynamodb_table = "mtp-state-locks"
    encrypt        = true
  }
}
