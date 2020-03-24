#!/bin/bash
 
PYTHON_PKGS=( python3 python3-venv )
#OTHER_PKGS=( ssh less vim )
 
# Install dependencies
apt update \
&& apt install -y "${PYTHON_PKGS[@]}" "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
 
# Setup custom ENC
PUP_CUSTOM_DIR=/etc/puppetlabs/local
git clone https://github.com/ncsa/puppetserver-local.git --depth=1 $PUP_CUSTOM_DIR \
&& $PUP_CUSTOM_DIR/configure.sh
