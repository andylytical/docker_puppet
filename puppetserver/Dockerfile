FROM puppet/puppetserver-standalone:5.3.7

ARG PUP_CUSTOM_DIR=/etc/puppetlabs/local

# Install python3
RUN apt update && \
    apt install -y python3 python3-venv && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Setup custom enc
# NOTE: puppetserver:5.3.7 is based on ubuntu v.16 which does not have
#       packages for Python 3.6, so must explicitly use py_ver_3.5 branch of
#       puppetserver-local
ENV PUP_CUSTOM_DIR=$PUP_CUSTOM_DIR
RUN git clone https://github.com/ncsa/puppetserver-local.git \
        --branch py_ver_3.5 \
        --single-branch \
        $PUP_CUSTOM_DIR && \
    $PUP_CUSTOM_DIR/configure.sh
