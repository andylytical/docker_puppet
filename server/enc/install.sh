#!/bin/bash
 
PYTHON_PKGS=( python3 python3-venv )
 
# Install dependencies
apt update \
&& apt install -y "${PYTHON_PKGS[@]}" "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
 
# Setup custom ENC
export QS_REPO=https://github.com/ncsa/puppetserver-enc.git
#export QS_GIT_BRANCH=better_setup_script
curl https://raw.githubusercontent.com/andylytical/quickstart/master/quickstart.sh | bash
