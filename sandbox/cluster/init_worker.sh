#!/bin/bash

sudo apt update
sudo apt install awscli -y

export INSTALL_RKE2_VERSION="v1.29.1+rke2r1"
export INSTALL_RKE2_CHANNEL="latest"

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sudo sh -

sudo systemctl enable rke2-agent.service

sleep 2m

sudo mkdir -p /etc/rancher/rke2
aws s3 cp s3://mtp-s3-bucket/rke-config.yaml /etc/rancher/rke2/config.yaml

sudo systemctl start rke2-agent.service
