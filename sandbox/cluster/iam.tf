# EC2 Instance IAM Role
resource "aws_iam_role" "node" {
  name = "${var.project_name}-node-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.node.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "node" {
  name = "${var.project_name}-node-profile"
  role = aws_iam_role.node.name
}
