#!/bin/bash

sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.7 virtualenv python3-pip python3.7-distutils -y
python3.7 --version
