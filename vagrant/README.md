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

## Configure r10k access to a git repo behind a firewall
TODO

## Debugging
- `server/tools/install.sh`

## Reset
- `cd; curl
  https://raw.githubusercontent.com/andylytical/docker_puppet/${QS_GIT_BRANCH:-master}/server/tools/reset.sh
  | bash`

## Secure access to a private git server
- Create an ssh key to use as a deploy key
  ```shell
  docker-compose exec puppet mkdir /etc/puppetlabs/r10k/ssh/
  docker-compose exec puppet ssh-keygen -t ed25519 -f /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  ```
- Install public portion of deploy key on the git server
  - Get public key contents
  ```shell
  docker-compose exec puppet cat /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key.pub
  ```
  - Install the public key contents (from above cmd) as a deploy key for the
    repo(s) on the private git server
  - Refer to your specific git server documentation for how to do this
- Create necessary ssh config to tunnel through any bastion/proxy hosts
  ```SSH Config
  # SAMPLE SSH CONFIG
  Host cerberus
      Hostname cerberus4.ncsa.illinois.edu
      User aloftus
  Host bastion
      Hostname lsst-bastion01.ncsa.illinois.edu
      User aloftus
      ProxyJump cerberus
  Host git-sec
      Hostname lsst-git.ncsa.illinois.edu
      User git
      PreferredAuthentications publickey
      IdentityFile /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
      ForwardX11 no
      ProxyJump bastion
  Host -
  ServerAliveInterval 60
  ServerAliveCountMax 3
  ControlMaster auto
  ControlPath ~/%l-%r@%h:%p
  ControlPersist 2d
  ```
  ```shell
  docker cp sample_ssh_config pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet chmod root:root /etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet ln -s /etc/puppetlabs/r10k/ssh /root/.ssh
  ```
- Initialize ssh connection from container to the secure git server
  ```shell
  # start a shell in the container
  docker-compose exec puppet bash
  # make initial connection to get-sec
  # ...will require manual login to bastion, proxy, etc.
  ssh -T git-sec
  # exit the container
  exit
  ```
- Verify non-interactive access (re-uses the authenticated channel created above)
  ```shell
  docker-compose exec puppet ssh -T git-sec
  ```
  Note: If password prompts continue, might have to login directly to each host
  in the path.  Check for files (inside the container), should have one per host:
  `/root/puppet.internal-<USER>@<HOST>:22=`
- Verify R10K has access to all repos defined in r10k.yaml
  ```shell
  bin/verify_repo_access
  ```




