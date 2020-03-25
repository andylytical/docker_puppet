# Based on examples from:
# https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-centos/Dockerfile
# https://hub.docker.com/r/centos/systemd/dockerfile

ARG CENTOS_VERSION
FROM centos:${CENTOS_VERSION}

ARG CENTOS_VERSION_MAJOR
ARG PUPPETAGENT_CERTNAME
ARG PUPPETAGENT_VERSION_MAJOR

# Install puppet yum repo and puppet agent yum pkgs
RUN rpm -Uvh https://yum.puppetlabs.com/puppet${PUPPETAGENT_VERSION_MAJOR}-release-el-${CENTOS_VERSION_MAJOR}.noarch.rpm && \
    yum install -y puppet-agent && \
    yum clean all
ENV PATH /opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Customize systemd for use inside container
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
STOPSIGNAL SIGRTMIN+3

# Install additional packages for puppet module dependencies
RUN yum install -y lvm2 which && \
    yum clean all

ENTRYPOINT ["init"]
