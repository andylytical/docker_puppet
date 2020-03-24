# docker_puppet

### Requirements
- [docker](https://www.docker.com/products/docker-desktop)
- [docker-compose](https://docs.docker.com/compose/install/)
- [pupperware](https://github.com/puppetlabs/pupperware)

# Quickstart

### Get pupperware
- `git clone https://github.com/puppetlabs/pupperware`
- `cd pupperware`

### Install customizations from this repo
- `export QS_REPO=https://github.com/andylytical/docker_puppet`
- `#export QS_GIT_BRANCH=branch_name`  (__optional__ - specify a branch other than master)
- `curl https://raw.githubusercontent.com/andylytical/quickstart/master/quickstart.sh | bash`

### Start puppetserver
- `docker-compose up -d`
- Ensure all containers are started and healthy
  - `docker-compose ps`

### Configure ENC
- Review [server/enc/tables.yaml](server/enc/tables.yaml)
- `server/enc/setup.sh`
- Verify enc setup
  - `bin/enc_adm -l`
  - `bin/enc_adm --help`

### Configure R10K
- Review [server/r10k/r10k.yaml](server/r10k/r10k.yaml)
- `server/r10k/setup.sh`
- `bin/verify_repo_access`
  - Resolve any errors before proceeding
- `bin/r10k`


# Other Actions

- [Puppet agent in docker](agent/README.md)
- [Puppet agent in Vagrant VM](vagrant/README.md)
- [Non-interactive access to a private git server (behind a firewall)](docs/ssh_tunnel.md)
- [Extras](docs/extras.md)
