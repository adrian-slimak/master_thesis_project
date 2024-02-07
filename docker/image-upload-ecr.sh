aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)
aws_region=$(aws configure get region)

aws ecr get-login-password | docker login -u AWS --password-stdin "https://${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"

docker tag celery-worker-image "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/mtp-worker:latest"
docker push "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/mtp-worker:latest"

docker tag flask-app-image "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/mtp-dashboard:latest"
docker push "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/mtp-dashboard:latest"