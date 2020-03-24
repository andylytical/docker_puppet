#!/bin/bash
 
PYTHON_PKGS=( python3 python3-venv )
#OTHER_PKGS=( ssh less vim )
 
# Install dependencies
apt update \
&& apt install -y "${PYTHON_PKGS[@]}" "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
 
# Custom R10K runner
R10K=/opt/puppetlabs/bin/r10k
R10K_TEMPLATE_URL='https://raw.githubusercontent.com/ncsa/puppet-r10k/master/templates/r10k_exec_wrapper_script.epp'
mkdir /var/log/r10k
curl -s "$R10K_TEMPLATE_URL" \
| sed -ne '/^#!\/bin\/bash/,$p' \
| sed -e '/^PIDFILE=/c\PIDFILE=/var/run/r10k' \
      -e '/^R10K=/c\R10K=/opt/puppetlabs/puppet/bin/r10k' \
      -e '/^LOGDIR=/c\LOGDIR=/var/log/r10k' \
>${R10K} \
&& chmod +x ${R10K} \
&& ln -s ${R10K} /
