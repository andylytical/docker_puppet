# Borrowed from (the now deprecated)
# https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-ubuntu/Dockerfile

FROM ubuntu:16.04

ARG PUPPET_VERSION="5.3.7"
ENV PUPPET_AGENT_VERSION=${PUPPET_VERSION} UBUNTU_CODENAME="xenial"

# Install puppet agent
RUN apt-get update && \
    apt-get install --no-install-recommends -y wget ca-certificates lsb-release && \
    wget https://apt.puppetlabs.com/puppet5-release-"$UBUNTU_CODENAME".deb && \
    dpkg -i puppet5-release-"$UBUNTU_CODENAME".deb && \
    rm puppet5-release-"$UBUNTU_CODENAME".deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y puppet-agent="$PUPPET_AGENT_VERSION"-1"$UBUNTU_CODENAME" && \
    apt-get remove --purge -y wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY Dockerfile /
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Install netcat
RUN apt-get update && \
  apt-get install -y netcat && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

# Install dumb-init
# See also:
# https://github.com/puppetlabs/puppetserver/blob/master/docker/puppetserver-standalone/Dockerfile
ARG DUMB_INIT_VERSION="1.2.2"
ADD https://github.com/Yelp/dumb-init/releases/download/v"$DUMB_INIT_VERSION"/dumb-init_"$DUMB_INIT_VERSION"_amd64.deb /dumb-init_"$DUMB_INIT_VERSION"_amd64.deb
RUN dpkg -i /dumb-init_"$DUMB_INIT_VERSION"_amd64.deb

# Copy entrypoint
COPY entrypoint.sh /usr/sbin/entrypoint
RUN chmod +x /usr/sbin/entrypoint

ENTRYPOINT ["dumb-init", "--", "entrypoint"]
CMD ["sleep", "infinity"]
