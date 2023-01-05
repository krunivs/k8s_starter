
# remove flannel
rm -rf /etc/cni/net.d/10-flannel.conflist
rm -rf /opt/cni/bin/flannel
kubectl delete -f "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

# remove weavenet
# rm -rf /opt/cni/bin/weavenet
# kubectl delete -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubeadm reset --force

