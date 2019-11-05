# docker_puppet

# Requirements

- [docker](https://www.docker.com/products/docker-desktop)
- [docker-compose](https://docs.docker.com/compose/install/)

# Quickstart
## Create Puppet server and agent
```shell
./doit.sh start
```

## Manually deploy environments with r10k
1. (optional) Modify r10k config file located at `custom/r10k/r10k.yaml`

1. Run r10k to deploy environments
   ```shell
   docker-compose exec puppet /r10k
   ```
   Note: No output indicates success. Otherwise, errors will be listed and the relevant logfile noted.


## Run puppet agent
```shell
docker exec -it agent-centos-1 puppet agent -t
```


## Test changes on a puppet module repo
After commiting changes on a "topic" branch of the repo:
1. Update enc for the node to use a topic branch
   ```shell
   docker exec -it server enc_adm --topic topic/aloftus/update_module_versions agent-centos-1.internal
   docker exec -it server enc_adm -l
   ```
1. Run puppet agent
   ```shell
   docker exec -it agent-centos-1 puppet agent -t
   ```


# Test puppet agent from a vagrant VM
See: [vagrant/README](vagrant/README.md)


# Additional examples
### Container Management
* Reset the entire environment to start from scratch
  ```shell
  ./doit.sh reset
  ```
* Remove containers and images, leave local customizations in place
  ```shell
  ./doit.sh clean
  ```
* Start puppet server only
  ```shell
  ./doit.sh start puppet
  ```
* Stop all containers
  ```shell
  ./doit.sh stop
  ```
* Stop only a specific container
  ```shell
  ./doit.sh stop <container_name>
  ```

### Puppet Agent
* Run puppet agent in **_dry run_** mode (don't make any changes, only list what would be done)
  ```shell
  docker exec -it agent-centos-1 puppet agent -t --noop
  ```
### Puppet Server
* Restart puppetserver (needed after, for instance, making config or cert changes)
  ```shell
  docker exec -it server pkill -HUP -u puppet java
  docker logs server #optional, to monitor server restart
  ```
* Exec a bash shell in the puppet master container
  ```shell
  docker-compose exec puppet bash
  ```
  OR
  ```shell
  docker exec -it server bash
  ```

### ENC (External Node Classifier)
* Add node `agent-centos-3` to enc
  ```shell
  docker exec -it server enc_adm --add --fqdn agent-centos-3.internal
  ```
* Check enc contents
  ```shell
  docker exec -it server enc_adm -l
  ```
1. Get more ENC help
  ```shell
  docker exec -it server enc_adm --help
  ```

### R10K Errors (ie: unable to sync repo to unresolvable ref)
R10K has a known issue [RK-323](https://tickets.puppetlabs.com/browse/RK-323) that
causes issues with cached values or modules. This workaround deletes all caches and
currently deployed modules.  It is safe to use always, even if the issue isn't 
currently happening, however it causes the r10k run to take
longer since all the repos and modules must be re-downloaded.
```shell
# workaround only - delete all currently deployed environments and r10k cache
docker-compose exec puppet bash -c 'rm -rf /etc/puppetlabs/code/* /var/cache/r10k'

# workaround , then re-run r10k deploy
docker-compose exec puppet bash -c 'rm -rf /etc/puppetlabs/code/* /var/cache/r10k; /r10k'
```

### Secure access to a private hiera repo
* Create an ssh key to use as a deploy key
  ```shell
  mkdir -p custom/r10k/ssh
  ssh-keygen -t ed25519 -f custom/r10k/ssh/private-hiera-deploy-key
  ```
* Install public portion of deploy key on the git server
  * Refer to your specific git server documentation
* Create necessary ssh config to tunnel through any bastion/proxy hosts
  ```shell
  vim -p custom/r10k/ssh/config
  ```
  ```SSH Config
  # SAMPLE SSH CONFIG
  Host bastion
      Hostname bastion.fqdn
      User your_user_name
  Host proxy
      Hostname proxy.fq.dn
      User a_valid_username
      ProxyCommand ssh -W %h:%p bastion
  Host git-sec
      Hostname git-secure.f.q.d.n
      User git
      PreferredAuthentications publickey
      IdentityFile /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
      ForwardX11 no
      ProxyCommand ssh -W %h:%p proxy
  Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  ControlMaster auto
  ControlPath ~/%l-%r@%h:%p
  ControlPersist 2d
  ```
* Link custom ssh directory to root's home inside the container
  ```shell
  docker-compose exec puppet ln -s /etc/puppetlabs/r10k/ssh /root/.ssh
  ```
* Initialize ssh connection from container to the secure git server
  ```shell
  docker-compose exec puppet ssh -T git-sec
  # above will require manual login to bastion, proxy, etc.
  ```
* Verify non-interactive login (re-uses the authenticated channel created above)
  ```shell
  docker-compose exec puppet ssh -T git-sec
  ```
* Ensure `r10k.yaml` uses ssh for access to private hiera
  * The "source" for private hiera should use the `git@server:repo` format, such as:
  ```YAML
  sources:
    private-hiera:
      remote: git@git-sec:lsst-it/hiera-private.git
  ```
* Verify r10k access to all repos listed in `r10k.yaml`
  ```shell
  docker-compose exec puppet bash -c 'awk "\$1==\"remote:\"{print \$NF}" /etc/puppetlabs/r10k/r10k.yaml | xargs -n1 git ls-remote'
  ```
  NOTE: from within container, just run:
  ```shell
  awk '$1=="remote:"{print $NF}' /etc/puppetlabs/r10k/r10k.yaml | xargs -n1 git ls-remote
  ```
* From now on, while puppetserver container is up, run r10k as usual...
  ```shell
  docker-compose exec puppet /r10k
  ```
