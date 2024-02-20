#!/bin/sh

sudo apt update

# export INSTALL_RKE2_VERSION="v1.29.1+rke2r1"
# export INSTALL_RKE2_CHANNEL="latest"

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sudo sh -

sudo systemctl enable rke2-agent.service

sudo mkdir -p /etc/rancher/rke2/
# sudo vim /etc/rancher/rke2/config.yaml

# sudo systemctl start rke2-agent.service
