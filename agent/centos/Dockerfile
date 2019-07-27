# Based on examples from:
# https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-centos/Dockerfile
# https://hub.docker.com/r/centos/systemd/dockerfile

FROM centos:7

ARG PUPPET_VERSION="5.3.7"
ARG DUMB_INIT_VERSION="1.2.2"
ARG PUPPET_AGENT_CERTNAME

# Install puppet yum repo and puppet agent yum pkgs
ENV PUPPET_AGENT_VERSION ${PUPPET_VERSION}
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum upgrade -y && \
    yum update -y && \
    yum install -y puppet-agent-"$PUPPET_AGENT_VERSION" && \
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
RUN yum install -y lvm2 && \
    yum clean all

# Install netcat (for network dependency checking in entrypoint)
RUN yum install -y nmap-ncat && \
    yum clean all


## Install dumb-init for better signal handling
#ADD https://github.com/Yelp/dumb-init/releases/download/v"${DUMB_INIT_VERSION}"/dumb-init_"${DUMB_INIT_VERSION}"_amd64 /usr/sbin/dumb-init
#RUN chmod +x /usr/sbin/dumb-init

# Copy entrypoint
ENV PUPPET_AGENT_CERTNAME $PUPPET_AGENT_CERTNAME
COPY entrypoint.sh /usr/sbin/entrypoint
RUN chmod +x /usr/sbin/entrypoint

#ENTRYPOINT ["dumb-init", "--", "entrypoint"]
#ENTRYPOINT ["init", "--", "entrypoint"]
ENTRYPOINT ["init"]
#CMD ["sleep", "infinity"]
