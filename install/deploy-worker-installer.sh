#!/bin/bash

root=$(dirname $(pwd))
k8s_install_dir="$root/install"
k8s_uninstall_dir="$root/uninstall"
config_dir="$root/config"
config_file="$root/config/cluster.conf"
config_check="$(pwd)/config.sh"
config="$root/config/cluster.conf"
rsa_key_file="/root/.ssh/id_rsa"
k8s_pkg_install_script="$(pwd)/install-k8s-pkg.sh"
master_join_script="$(pwd)/join-master.sh"
uninstall_k8s_pkg_script="$root/uninstall/uninstall-k8s-pkg.sh"


#######################################################################################
# ENTRY POINT
#######################################################################################

# check configuration
$config_check
if [ $? -eq 1 ]; then
  echo "[ERROR] Fail to configuration"
fi

source $config

if [ -v $WORKERS ] || [ ${#WORKERS[@]} -eq 0 ]; then
  echo "[ERROR] Not exist WORKERS variable or value in $config"
  echo "Fill worker ip to WORKERS variable in $config"
  echo "e.g., WORKERS=("192.168.0.1" "192.168.0.2")"
  exit 1    
fi

if [ ! -f $master_join_script ]; then
  echo "[ERROR] Not exist $master_join_script file, you must execute install-master.sh, firstly"
  exit 1
fi

# deploy rsa key
if [ ! -f $rsa_key_file ]; then
# if not exist rsa key in master node, create rsa key    
  echo "# Execute ssh-keygen -t rsa"
  ssh-keygen -t rsa
  echo "# Generate rsa key ... [OK]"
fi


# deploy script to workers
for host in ${WORKERS[@]};
do
  # create directory for copied script
  ssh root@$host mkdir -p $k8s_install_dir
  ssh root@$host mkdir -p $k8s_uninstall_dir
  ssh root@$host mkdir -p $config_dir

  # deploy scripts  
  echo "## Copy $config_file to root@$host:$config_file"
  scp $config_file root@$host:$config_file
  echo "## Deploy $config_file ... [OK]"

  echo "## Copy $config_check to root@$host:$config_check"
  scp $config_check root@$host:$config_check
  echo "## Deploy $config_check ... [OK]"

  echo "## Copy $k8s_pkg_install_script to root@$host:$k8s_pkg_install_script"
  scp $k8s_pkg_install_script root@$host:$k8s_pkg_install_script
  echo "## Deploy $k8s_pkg_install_script ... [OK]"
  
  echo "## Copy $uninstall_k8s_pkg_script to root@$host:$k8s_pkg_install_script"
  scp $uninstall_k8s_pkg_script root@$host:$uninstall_k8s_pkg_script
  echo "## Deploy $uninstall_k8s_pkg_script ... [OK]"

  echo "## Copy $master_join_script to root@$host:$master_join_script"
  scp $master_join_script root@$host:$master_join_script
  echo "## Deploy $master_join_script ... [OK]"  
done
