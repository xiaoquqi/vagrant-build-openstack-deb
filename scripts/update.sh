#!/bin/bash

# This script is used to update source list and apt configuration files

UBUNTU_MIRROR=mirrors.sohu.com

cat << EOF | tee /etc/apt/sources.list
deb http://$UBUNTU_MIRROR/ubuntu/ precise main restricted
deb http://$UBUNTU_MIRROR/ubuntu/ precise-updates main restricted
deb http://$UBUNTU_MIRROR/ubuntu/ precise universe
deb http://$UBUNTU_MIRROR/ubuntu/ precise-updates universe
deb http://$UBUNTU_MIRROR/ubuntu/ precise multiverse
deb http://$UBUNTU_MIRROR/ubuntu/ precise-updates multiverse
deb http://$UBUNTU_MIRROR/ubuntu/ precise-backports main restricted universe multiverse
deb http://$UBUNTU_MIRROR/ubuntu/ precise-security main restricted
deb http://$UBUNTU_MIRROR/ubuntu/ precise-security universe
deb http://$UBUNTU_MIRROR/ubuntu/ precise-security multiverse
deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main
EOF

cat << EOF | tee /etc/apt/apt.conf.d/90forceyes
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
EOF

apt-get update

# As we will build havana package, so we should include havana source.
# We can install neccessary dependency from it. Here we add key.
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5EDB1B62EC4926EA
