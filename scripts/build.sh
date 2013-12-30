#!/bin/bash

# This script is a build demo for OpenStack in Havana.

# Install Build Tools
# ===================

# devscripts depends on nullmailer, this will need users to enter information
# interactive and break the vm start, set this before install devscripts
debconf-set-selections <<\EOF
nullmailer shared/mailname string buildtest
nullmailer nullmailer/relayhost string buildtest.com smtp --auth-login --user=username --pass=password
EOF

apt-get install -y debootstrap equivs schroot
apt-get install -y devscripts
apt-get install -y build-essential checkinstall sbuild
apt-get install -y dh-make
apt-get install -y bzr bzr-builddeb
apt-get install -y git

apt-get install -y python-setuptools

# Download Source Code
# ====================

UBUNTU_RELEASE=precise
OPENSTACK_RELEASE=havana
BUILD_HOME=$HOME/build
PROJECT=glance
SOURCE_DIR="${PROJECT}_source"
DEBIAN_DIR=$PROJECT
SOURCE_PATH=$BUILD_HOME/$SOURCE_DIR
DEBIAN_PATH=$BUILD_HOME/$DEBIAN_DIR
mkdir -p $BUILD_HOME

cd $BUILD_HOME
if [ ! -e $SOURCE_PATH ]; then
  git clone https://code.csdn.net/openstack/${PROJECT}.git --branch "stable/${OPENSTACK_RELEASE}" $SOURCE_PATH
fi

if [ ! -e $DEBIAN_PATH ]; then
  bzr branch "lp:~ubuntu-server-dev/${PROJECT}/${OPENSTACK_RELEASE}" $DEBIAN_PATH
fi

# install pip and pbr, build script will auto download pip and consider
# as they are the source code of our project and make the build failed
# install it in the system directory will avoid this problem
PIP_PKG_PATH=/vagrant/pip
INST_PIP_PATH=$BUILD_HOME/python
if [ ! -e $INST_PIP_PATH ]; then
  mkdir -p $INST_PIP_PATH
fi
PIP_FILE=pip-1.4.1.tar.gz
cp $PIP_PKG_PATH/$PIP_FILE $INST_PIP_PATH
cd $INST_PIP_PATH
tar zxvf $PIP_FILE

cd $INST_PIP_PATH/pip-1.4.1
python setup.py install
pip install pbr

SOURCE_DIST_PATH=$SOURCE_PATH/dist
rm -rf $SOURCE_DIST_PATH
cd $SOURCE_PATH
python setup.py sdist

# Generate Source Package
# =======================

# Using python setup.py to generate package
cd $SOURCE_DIST_PATH
PKG_FILENAME=$(ls *.tar.gz -1)
VERSION=$(echo $PKG_FILENAME | cut -f2 -d"-" | sed 's/\.tar\.gz//')
PROJECT_NAME=$(ls *.tar.gz | cut -f1 -d"-")
mv $SOURCE_DIST_PATH/$PKG_FILENAME $BUILD_HOME/${PROJECT_NAME}_${VERSION}~${UBUNTU_RELEASE}.orig.tar.gz

# Generate Commit Log
# ===================

# Generate commit log based on the version generated above
cd $DEBIAN_PATH
dch -b -D precise --newversion "1:${VERSION}~${UBUNTU_RELEASE}-0ubuntu1" 'This is a build test.'
debcommit

# Install Dependencies & Build Deb Packages
# =========================================

cd $DEBIAN_PATH
mk-build-deps -i -t 'apt-get -y' debian/control
bzr builddeb -- -sa -us -uc
