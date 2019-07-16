# Borrowed from (the now deprecated) ...
# https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-centos/Dockerfile

FROM centos:7

ARG PUPPET_VERSION="5.3.7"
ENV PUPPET_AGENT_VERSION=${PUPPET_VERSION}

# Install puppet yum repo and puppet agent yum pkgs
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum upgrade -y && \
    yum update -y && \
    yum install -y puppet-agent-"$PUPPET_AGENT_VERSION" && \
    yum clean all

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Install netcat (for network dependency checking in entrypoint)
RUN yum install -y nmap-ncat && \
    yum clean all

# Install dumb-init for better signal handling
ARG DUMB_INIT_VERSION="1.2.2"
ADD https://github.com/Yelp/dumb-init/releases/download/v"${DUMB_INIT_VERSION}"/dumb-init_"${DUMB_INIT_VERSION}"_amd64 /dumb-init
RUN chmod +x /dumb-init
ENTRYPOINT ["/dumb-init", "--"]

COPY entrypoint.sh /usr/sbin/entrypoint
CMD [ "entrypoint" ]
