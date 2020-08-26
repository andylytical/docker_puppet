#!/bin/bash
 
PYTHON_PKGS=( python3 python3-venv )
 
# Install dependencies
apt update \
&& apt install -y "${PYTHON_PKGS[@]}" "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
 
# Setup custom ENC
PUP_ENC_DIR=/etc/puppetlabs/enc
git clone https://github.com/ncsa/puppetserver-enc.git --depth=1 $PUP_ENC_DIR \
&& $PUP_ENC_DIR/setup.sh
