# Secure access to a private git server

### Create an ssh key to use as a deploy key
```shell
docker-compose exec puppet mkdir /etc/puppetlabs/r10k/ssh/
docker-compose exec puppet bash -c 'apt update && apt install -y ssh && apt clean && rm -rf /var/lib/apt/lists/*'
```
- For production use-case:
  - Create an ssh key for deployment
  ```shell
  docker-compose exec puppet ssh-keygen -t ed25519 -f /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  ```
- For local testing:
  ```shell
  docker cp ~/.ssh/id_ed25519 pupperware_puppet_1:/etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  docker-compose exec puppet chown root:root /etc/puppetlabs/r10k/ssh/private-hiera-deploy-key
  ```

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

### Install ssh
```shell
docker cp server/ssh/install.sh pupperware_puppet_1:/install_ssh.sh
docker-compose exec puppet /install_ssh.sh
```

### Configure ssh
- Adjust settings in `server/ssh/config` as appropriate for your setup
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
`/root/puppet.internal-<USER>@<HOST>:22=`

### Verify R10K has access to all repos defined in r10k.yaml
```shell
bin/verify_repo_access
```
