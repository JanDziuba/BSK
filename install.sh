#!/bin/bash

apt-get -y update
apt-get -y install apt-utils
apt-get -y install sudo
apt-get -y install build-essential
apt-get -y install acl
apt-get -y install libpam0g-dev
apt-get -y install openssh-server

# install python3
apt-get install -y python3-pip python3-dev
cd /usr/local/bin
ln -s /usr/bin/python3 python
pip3 --no-cache-dir install --upgrade pip
rm -rf /var/lib/apt/lists/*

pip install -r /app/client_project/requirements.txt
