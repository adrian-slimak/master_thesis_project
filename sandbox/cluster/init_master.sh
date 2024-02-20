#!/bin/sh

sudo apt update

# export INSTALL_RKE2_VERSION="v1.29.1+rke2r1"
# export INSTALL_RKE2_CHANNEL="latest"

# master
curl -sfL https://get.rke2.io | sudo sh -
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

TOKEN="$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")"
HOSTNAME="$(curl http://169.254.169.254/latest/meta-data/local-ipv4 -H "X-aws-ec2-metadata-token: $TOKEN")"
TOKEN="$(sudo cat /var/lib/rancher/rke2/server/node-token)"

echo "server: https://$HOSTNAME:9345" > rke-config.yaml
echo "token: $TOKEN" >> rke-config.yaml

sudo snap install kubectl --classic
sudo cp /etc/rancher/rke2/rke2.yaml .kube/config