# Borrowed from (the now deprecated) ...
# https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-centos/Dockerfile

FROM centos:7

ENV PUPPET_AGENT_VERSION="5.5.1"

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
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /dumb-init
RUN chmod +x /dumb-init
ENTRYPOINT ["/dumb-init", "--"]

COPY entrypoint.sh /usr/sbin/entrypoint
CMD [ "entrypoint" ]
