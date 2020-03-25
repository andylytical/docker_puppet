#!/bin/bash

apt update \
&& apt install -y ssh \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*
