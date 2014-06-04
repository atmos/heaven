#!/bin/sh

####
# This script can be used to setup development (vagrant) environments
####

###
# Set correct locale
###
echo "Setting locale"
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

###
# Update apt-get
###
echo "Updating apt-get"
apt-get -qq update

echo "Installing libraries from apt-get"
apt-get -qq install curl build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev git-core libpq-dev

### 
# Install latest git
###
echo "Installing/updating git"
apt-get -qq install python-software-properties
add-apt-repository ppa:git-core/ppa
apt-get -qq update
apt-get -qq install git

### 
# Install basic ruby for chef
# Releases can be found at http://ftp.ruby-lang.org/pub/ruby/2.0/
###
RUBY_RELEASE=ruby-2.0.0-p451
echo "Installing ${RUBY_RELEASE} for chef"

cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/2.0/${RUBY_RELEASE}.tar.gz
tar -xvzf ${RUBY_RELEASE}.tar.gz
cd ${RUBY_RELEASE}/
./configure --prefix=/usr/local
make
make install

###
# Install chef-solo
###
echo "Installing chef & librarian"
cd /vagrant
gem install chef librarian-chef --no-rdoc --no-ri --conservative
# chef is now installed as `chef-solo`

###
# Download cookbooks for chef
###
echo "Installing cookbooks"
cd /vagrant
librarian-chef install