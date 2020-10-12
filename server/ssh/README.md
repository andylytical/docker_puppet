# Setup Secure Access To A Private Git Server
These steps are needed to access a git repo on a server that is behind a firewall. The general process is:
- Setup an ssh key for access to the repo (on the git server)
- Create a persistent ssh tunnel for access to the git server

### SSH deploy key
Note:
- Must have a deploy key setup on the private git server.
- For production use, suggest a separate key per puppet master.
- These instructions assume an appropriate deploy key has already been created
  and installed on the private git server.
  - For additional help, see:
    - [GitHub](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
    - [GitLab](https://docs.gitlab.com/ce/ssh/README.html)

Setup session environment variables for the appropriate ssh deploy key.
Adjust the path here to point to the private ssh key to use.
```shell
export DEPLOYKEY=~/.ssh/r10k.deploy.key
```
Commands below will use this session environment variable.

---

### Install private portion of deploy key in the container
```shell
docker-compose exec puppet mkdir /etc/puppetlabs/r10k/ssh/
docker cp -L "$DEPLOYKEY" pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
```

### Install ssh in the container
```shell
docker cp -L server/ssh/install.sh pupperware_puppet_1:/install_ssh.sh
docker-compose exec puppet /install_ssh.sh
```

### Configure ssh
- Adjust settings in `server/ssh/config` as appropriate for your setup
  ```shell
  vim server/ssh/config
  ```
- Copy ssh config into container
  ```shell
  docker cp -L server/ssh/config pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/config
  docker-compose exec puppet rm -rf /root/.ssh
  docker-compose exec puppet ln -s /etc/puppetlabs/r10k/ssh /root/.ssh
  ```

---

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

---

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
