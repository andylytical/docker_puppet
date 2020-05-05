# docker_puppet

### Requirements
- [docker](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [pupperware](https://github.com/puppetlabs/pupperware)

# Quickstart

---

### Get pupperware
- `git clone https://github.com/puppetlabs/pupperware`
- `cd pupperware`

Note: All commands below are expected to be run from inside the pupperware
directory.

---

### Install customizations from this repo
- `export QS_REPO=https://github.com/andylytical/docker_puppet`
- `#export QS_GIT_BRANCH=branch_name`  (__optional__ - specify a branch other than master)
- `curl https://raw.githubusercontent.com/andylytical/quickstart/master/quickstart.sh | bash`

### Review .env settings
- `vim .env`

---

### Start puppetserver
- `docker-compose up -d`
- Ensure all containers are started and healthy
  - `docker-compose ps`

---

### Configure ENC
- Review enc table layout
  - `vim server/enc/tables.yaml`
    - Note: for more about enc: [ncsa/puppetserver-local](https://github.com/ncsa/puppetserver-local)
- Install enc in the container
  - `server/enc/setup.sh`
- Verify enc setup
  - `bin/enc_adm -l`
  - `bin/enc_adm --help`

---

### Configure R10K
- Review r10k configuration
  - `vim server/r10k/r10k.yaml`
- Apply r10k config in the container
  - `server/r10k/setup.sh`
- Verify r10k can access all the repos in it's config
  - `bin/verify_repo_access`
  - Resolve any errors before proceeding
    - See also:
      [Non-interactive access to a private git server (behind a firewall)](server/ssh/README.md)
- Run R10K
  - `bin/r10k`
  - No output means successful run. In the case of errors, view latest log file
    with:
    - `bin/r10k_log`

---

# Other Actions

- [Add nodes to the ENC](docs/enc.md)
- [Puppet agent in Vagrant VM](vagrant/README.md)
- [Non-interactive access to a private git server (behind a firewall)](server/ssh/README.md)
- [Extras](docs/extras.md)
