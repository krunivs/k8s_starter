# k8s_starter
kubernetes installer

## Description
This repository contains install/uninstall scripts for kubernetes 1.20-00 cluster.

## Getting started

### Install master node
* Clone repository to master node
```
$ git clone https://github.com/krunivs/k8s_starter.git
```

* Edit cluster configurtation file: modify worker node's IP address in WORKERS(i.e., "10.0.0.207" "10.0.0.208", "10.0.0.209")
```
$ cd [path-to-project-root]
$ vi config/cluster.conf
K8S_VERSION=1.21.0-00
POD_NETWORK_CIDR=10.244.0.0/16  # flannel must use 10.244.0.0/16. do not edit
SERVICE_CIDR=10.55.0.0/16
API_SERVER_IP=$(hostname -I | cut -d' ' -f1)
WORKERS=("10.0.0.207")
```

* Install docker and kubernetes packages
```
$ cd [path-to-project-root]/install
$ ./install-k8s-pkg.sh
```


* Install master node
```
$ cd [path-to-project-root]/install
$ ./install-master.sh
```


* Deploy worker node's install scripts
```
$ cd [path-to-project-root]/install
$ ./deploy-worker-installer.sh
```

### Install worker node

* Access worker node's ssh and install docker and kubernetes packages
```
$ cd /root/kubernetes/install
$ ./install-k8s-pkg.sh
```


* Join to master node
```
$ cd /root/kubernetes/install
$ ./join-master.sh
```
