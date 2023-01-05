# !/bin/bash
set -e

# uninstall docker ce
sudo apt-get purge -y docker* containerd runc

# uninstall kubelet kubeadm kubectl kubernetes-cni
apt-get purge -y kubelet kubeadm kubectl kubernetes-cni

apt-get clean
apt-get update
