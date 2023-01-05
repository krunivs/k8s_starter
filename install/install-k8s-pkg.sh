# !/bin/bash
#set -e

root=$(dirname $(pwd))
config=$root/config/cluster.conf
config_check="$(pwd)/config.sh"

# check configuration
$config_check
if [ $? -eq 1 ]; then
  echo "[ERROR] Fail to configuration"
fi

source $config

# clean and install base package
apt-get autoclean
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https curl

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
docker version > /var/docker.version
cat /var/docker.version

sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable containerd
sudo systemctl start containerd

# set k8s configuration
## disable firewall
ufw disable

## disk swap off
sudo swapoff -a && sudo sed -i '/swap/s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system


# add package repository
rm -rf /etc/apt/sources.list.d/kubernetes.list*
rm -rf /etc/apt/sources.list.save

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

# install kubelet kubeadm kubectl
apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION kubernetes-cni
apt-mark hold kubelet kubeadm kubectl

# kubelet restart
systemctl daemon-reload
systemctl restart kubelet
