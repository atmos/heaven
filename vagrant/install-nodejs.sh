#!/bin/sh

echo "Installing nodejs"
apt-get -qq install software-properties-common
apt-get -qq update
apt-get -qq install -y python-software-properties python g++ make
add-apt-repository -y ppa:chris-lea/node.js
apt-get -qq update
apt-get -qq install nodejs