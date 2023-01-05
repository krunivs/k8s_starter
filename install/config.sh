#!/bin/bash

root=$(dirname $(pwd))
config=$root/config/cluster.conf



# check config
if [ ! -f $config ]; then
    echo "[ERROR] Not exist $config file"
    exit 1
fi
source $config

if [ -v $POD_NETWORK_CIDR ] || [ -z $POD_NETWORK_CIDR ]; then
  echo "[ERROR] Not exist POD_NETWORK_CIDR variable or value in $config"
  exit 1
fi

if [ -v $SERVICE_CIDR ] || [ -z $SERVICE_CIDR ]; then
  echo "[ERROR] Not exist SERVICE_CIDR variable or value in $config"
  exit 1
fi
if [ -v $API_SERVER_IP ] || [ -z $API_SERVER_IP ]; then
  echo "[ERROR] Not exist API_SERVER_IP variable or value in $config"
  exit 1
fi
if [ -v $WORKERS ] && [ ${#WORKERS[@]} -gt 0 ]; then
  echo "[ERROR] Not exist WORKERS variable or value in $config"
  echo "Fill worker ip to WORKERS variable in $config"
  echo "e.g., WORKERS=("192.168.0.1" "192.168.0.2")"
  exit 1
else
    n_workers=${#WORKERS[@]}
fi