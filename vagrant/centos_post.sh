#!/bin/bash

PKGLIST=( \
  bind-utils \
  git \
  iproute \
  less \
  lsof \
  lvm2 \
  net-tools \
  tree \
  vim \
  which \
  python36-tools
)

set -x

# Ensure EPEL repo is installed
yum -y install epel-release

# Install packages
yum -y install "${PKGLIST[@]}"

# Clean up
yum clean all
