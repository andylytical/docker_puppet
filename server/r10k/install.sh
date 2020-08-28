#!/bin/bash
 
PYTHON_PKGS=( python3 python3-venv )
OTHER_PKGS=( git )
 
# Install dependencies
apt update \
&& apt install -y "${PYTHON_PKGS[@]}" "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

# Custom R10K runner and config
export PUP_R10K_DIR=/etc/puppetlabs/r10k
git clone https://github.com/ncsa/puppetserver-r10k.git "$PUP_R10K_DIR"
"$PUP_R10K_DIR"/setup.sh
