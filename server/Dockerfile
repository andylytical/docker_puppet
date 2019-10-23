ARG PUPPET_VERSION="5.3.7"
FROM puppet/puppetserver:${PUPPET_VERSION}

ARG PUP_CUSTOM_DIR=/etc/puppetlabs/local

# Install python3 (needed for r10k and enc)
RUN apt update && \
    apt install -y python3 python3-venv less && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Custom r10k runner
ARG R10K=/opt/puppetlabs/bin/r10k
RUN curl -s https://raw.githubusercontent.com/ncsa/puppet-r10k/master/templates/r10k_exec_wrapper_script.epp \
    | sed -ne '/^#!\/bin\/bash/,$p' \
    | sed -e '/^PIDFILE=/c\PIDFILE=/var/run/r10k' \
          -e '/^R10K=/c\R10K=/opt/puppetlabs/puppet/bin/r10k' \
          -e '/^LOGDIR=/c\LOGDIR=/etc/puppetlabs/r10k/logs' \
    >${R10K} \
    && chmod +x ${R10K} \
    && ln -s ${R10K} /
ENV PATH=/:$PATH
#          -e '/^LOGFILE=/c\LOGFILE="${LOGDIR}/deploy.log"'

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

# Install ssh (needed for tunneled access to firewalled resources)
RUN apt update && \
    apt install -y ssh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
