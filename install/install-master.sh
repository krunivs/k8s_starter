#! /bin/bash
# set -e

root=$(dirname $(pwd))
master_join_script="$(pwd)/join-master.sh"
config_check="$(pwd)/config.sh"
config="$root/config/cluster.conf"

function delete_interface {
  if [[ -d /sys/class/net/${1} ]]; then
    ifconfig ${1} down
    ip link delete ${1}
  fi
}

rm -f /root/.kube/config

# check configuration
$config_check
if [ $? -eq 1 ]; then
  echo "[ERROR] Fail to configuration"
fi

source $config

# check setup variables for backup
if [ -v $POD_NETWORK_CIDR ] || [ -z $POD_NETWORK_CIDR ]; then
  echo "not exist POD_NETWORK_CIDR variable in ./cluster.conf"
  exit 1
fi

if [ -v $SERVICE_CIDR ] || [ -z $SERVICE_CIDR ]; then
  echo "not exist SERVICE_CIDR variable in ./cluster.conf"
  exit 1
fi
if [ -v $API_SERVER_IP ] || [ -z $API_SERVER_IP ]; then
  echo "not exist API_SERVER_IP variable in ./cluster.conf"
  exit 1
fi

# delete CNI interface
delete_interface flannel.1
delete_interface weave
# delete_interface cni0

# init kubeadm
kubeadm init \
--pod-network-cidr $POD_NETWORK_CIDR \
--service-cidr $SERVICE_CIDR \
--apiserver-advertise-address $API_SERVER_IP | tee | tail -n2 > $master_join_script

chmod 755 $master_join_script

# configure kubernetes
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.profile
source ~/.profile

# install CNI 
# weavenet
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=$POD_NETWORK_CIDR"
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# flannel
kubectl apply -f "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
systemctl restart kubelet

# setup kubernetes helper
source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.

source <(kubeadm completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubeadm completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
