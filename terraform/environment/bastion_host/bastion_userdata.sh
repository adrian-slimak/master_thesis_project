#!/bin/bash

export BUCKET_NAME=${bucket_name}
export SSH_KEY_NAME=${ssh_key_name}

# Install utils and aws cli v2
sudo yum update -y
sudo yum install jq -y
sudo yum install awscli -y
sudo yum instal wget

sleep 5m

# Download cluster config file and ssh key from S3 bucket
aws s3 cp s3://$BUCKET_NAME/cluster.yml ./cluster.yml
aws s3 cp s3://$BUCKET_NAME/$SSH_KEY_NAME ./k8s-ssh-key.pem
chmod 400 ./k8s-ssh-key.pem

# Download RKE
curl -LO https://github.com/rancher/rke/releases/download/v1.4.9/rke_linux-amd64 && chmod a+x ./rke_linux-amd64
mv rke_linux-amd64 rke

# Provision RKE cluster
./rke up --config ./cluster.yml --ignore-docker-version

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

sudo rm -r kubectl
sudo rm kubectl.sha256

wget https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz
tar xvf helm-v3.9.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin
rm helm-v3.9.3-linux-amd64.tar.gz
rm -rf linux-amd64

# export KUBECONFIG=./kube_cluster_config.yml
