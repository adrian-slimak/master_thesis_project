#!/bin/bash

# Redirect stdout and stderr to file
exec &> /var/log/init-kubernetes-master.log

set -o verbose
set -o errexit
set -o pipefail

export CLUSTER_NAME=${cluster_name}
export KUBERNETES_VERSION="1.28.0"

# Set this only after setting the defaults
set -o nounset

# Disable SELinux
# setenforce returns non zero if already SE Linux is already disabled
is_enforced=$(getenforce)
if [[ $is_enforced != "Disabled" ]]; then
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
fi

# Disable swap
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

###
# Install containerd
###

# cat <<EOF | tee /etc/modules-load.d/containerd.conf
# overlay
# br_netfilter
# EOF

# modprobe overlay
# modprobe br_netfilter

# # Setup required sysctl params, these persist across reboots.
# cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
# net.bridge.bridge-nf-call-iptables  = 1
# net.ipv4.ip_forward                 = 1
# net.bridge.bridge-nf-call-ip6tables = 1
# EOF

# # Apply sysctl params without reboot
# sysctl --system

# yum install yum-utils -y
# # yum install -y yum-utils curl gettext device-mapper-persistent-data lvm2
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# # sudo yum install -y containerd.io
# yum install containerd.io -y
# mkdir -p /etc/containerd
# containerd config default > /etc/containerd/config.toml
# sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# systemctl restart containerd
# systemctl enable containerd