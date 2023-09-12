#!/bin/bash

export BUCKET_NAME=${bucket_name}

# Install utils and aws cli v2
sudo yum update -y
sudo yum install jq -y
sudo yum install wget -y
sudo yum install awscli -y

# Install yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.12.0/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# Commands for all K8s nodes
sudo yum update -y
sudo yum install docker -y

# Disable SELinux
# setenforce returns non zero if already SE Linux is already disabled
is_enforced=$(getenforce)
if [[ $is_enforced != "Disabled" ]]; then
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
fi

# Turn off swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Confirm that docker group has been created on system
sudo groupadd docker

# Add current system user to the Docker group, as well as the ec2-user user
sudo gpasswd -a $USER docker
sudo usermod -a -G docker ec2-user
grep /etc/group -e "docker"

# Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

# Modify bridge adapter setting
# Configure sysctl.
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Ensure that the br_netfilter module is loaded
lsmod | grep br_netfilter

# Download cluster yaml file from S3 bucket
aws s3 cp s3://$BUCKET_NAME/cluster.yml ./

# Get the value of the existing number of nodes listed in the config file and use that
# number for creating a new node listing in the array
# aws configure set region $AWS_REGION
TOKEN="$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")"
export HOSTNAME="$(curl http://169.254.169.254/latest/meta-data/local-ipv4 -H "X-aws-ec2-metadata-token: $TOKEN")"
export NUMBER_OF_NODES="$(yq eval '.nodes | length' cluster.yml)"
yq eval -i '
  .nodes[env(NUMBER_OF_NODES)].address = env(HOSTNAME) |
  .nodes[env(NUMBER_OF_NODES)].user = "ec2-user" |
  .nodes[env(NUMBER_OF_NODES)].role[0] = "controlplane" |
  .nodes[env(NUMBER_OF_NODES)].role[1] = "etcd"
' ./cluster.yml

# Upload the cluster.yml file to S3 bucket
aws s3 cp ./cluster.yml s3://$BUCKET_NAME
