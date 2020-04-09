# Secure access to a private git server
These steps are needed to access a git repo on a server that is behind a firewall. The general process is:
- Create a persistent ssh tunnel for access to the git server
- Setup an ssh key for access to the repo (on the git server)

NOTE: In the commands below, replace the source file `~/.ssh/$(hostname)-r10k` with the actual path
to the ssh key file(s) on the local host.

### First time only - create a new ssh key pair (if needed)
For production use, suggest a separate key per puppet master.
```shell
ssh-keygen -t ed25519 -f ~/.ssh/$(hostname)-r10k
```

### Install private portion of deploy key in the container
```shell
docker-compose exec puppet mkdir /etc/puppetlabs/r10k/ssh/
docker cp ~/.ssh/$(hostname)-r10k pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
```


### Install public portion of deploy key on the git server
- Get public key contents
```shell
cat ~/.ssh/$(hostname)-r10k.pub
```
- Install the public key contents (from above cmd) as a deploy key for the
  repo(s) on the private git server
- Refer to your specific git server documentation for how to do this

### Install ssh in the container
```shell
docker cp server/ssh/install.sh pupperware_puppet_1:/install_ssh.sh
docker-compose exec puppet /install_ssh.sh
```

### Configure ssh
- Adjust settings in `server/ssh/config` as appropriate for your setup
  ```shell
  vim server/ssh/config
  ```
- Copy ssh config into container
  ```shell
  docker cp server/ssh/config pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet ln -s /etc/puppetlabs/r10k/ssh /root/.ssh
  ```

### Initialize ssh connection from container to the secure git server
```shell
# start a shell in the container
docker-compose exec puppet bash
# make initial connection to get-sec
# ...will require manual login to bastion, proxy, etc.
ssh -T git-sec
# exit the container
exit
```

### Verify non-interactive access (re-uses the authenticated channel created above)
```shell
docker-compose exec puppet ssh -T git-sec
```
Note: If password prompts continue, might have to login directly to each host
in the path.  Check for files (inside the container), should have one per host:
`/root/puppet.test.local-<USER>@<HOST>:22=`

### Verify R10K has access to all repos defined in r10k.yaml
```shell
bin/verify_repo_access
```
