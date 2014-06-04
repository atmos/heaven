#!/bin/sh

###
# heroku
# This is done explicity via the expanded script steps because heroku's certificates give
# lucid a headache and a half.
###
echo "Installing heroku toolbelt"

# add heroku repository to apt
echo "deb http://toolbelt.heroku.com/ubuntu ./" > /etc/apt/sources.list.d/heroku.list

# install heroku's release key for package verification
wget -O- --no-check-certificate https://toolbelt.heroku.com/apt/release.key | apt-key add -

# update your sources
apt-get update

# install the toolbelt
apt-get install -y --force-yes heroku-toolbelt

###
# Cleanup
###
echo "Restoring cookbook folder"
cd /vagrant
git checkout -- cookbooks/.keep

###
# Hurrah!
###
echo "Server setup completed. Login using 'vagrant ssh'"