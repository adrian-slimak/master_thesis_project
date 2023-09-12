# Create private key
resource "tls_private_key" "tls_key" {
  algorithm = "ED25519"
}

# Create keypair
resource "aws_key_pair" "key_pair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.tls_key.public_key_openssh

  # generate "key.pem" in current directory
  provisioner "local-exec" {
    # interpreter = ["powershell", "-Command"]
    command = <<-eot
      rm -f ./${var.key_file_name}
      echo '${tls_private_key.tls_key.private_key_openssh}' > ./${var.key_file_name}
      chmod 400 ./${var.key_file_name}
    eot
  }
}

# Save private key to s3 bucket
resource "aws_s3_object" "key_object" {
  key     = var.key_file_name
  bucket  = var.bucket_name
  content = tls_private_key.tls_key.private_key_openssh
}
