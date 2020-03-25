#!/bin/bash
 
OTHER_PKGS=( ssh less vim )
 
# Install dependencies
apt update \
&& apt install -y "${OTHER_PKGS[@]}" \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
 
