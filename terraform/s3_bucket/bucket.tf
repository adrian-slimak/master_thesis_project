# S3 Bucket

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# resource "aws_s3_bucket_versioning" "bucket_versioning" {
#  bucket = aws_s3_bucket.terraform_state.id

#  versioning_configuration {
#   status = "Enabled"
#  }
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB

resource "aws_dynamodb_table" "state_locks" {
  name         = var.state_locks_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
