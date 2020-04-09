# Secure access to a private git server

### First time only - create a new ssh key pair (if needed)
For production use, suggest a separate key per puppet master.
- Create ssh key to use as a deploy key
```shell
ssh-keygen -t ed25519 -f ~/.ssh/$(hostname)-r10k
```

### Install private portion of deploy key in the container
- Create the target dir in the container
```shell
docker-compose exec puppet mkdir /etc/puppetlabs/r10k/ssh/
```
- Copy the private key file into the container
  ```shell
  docker cp ~/.ssh/$(hostname)-r10k pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  ```
  NOTE: replace the source file `~..ssh/$(hostname)-r10k` with the actual path
  to the private key file on the local host.

### Install public portion of deploy key on the git server
- Get public key contents
  - For production use-case:
    ```shell
    docker-compose exec puppet cat /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key.pub
    ```
  - For local testing:
    ```shell
    cat ~/.ssh/id_ed25519.pub
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
