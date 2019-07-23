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

1. Exec a bash shell in the running container
   ```shell
   docker-compose exec puppet bash
   ```

1. Run r10k to deploy environments
   ```shell
   r10k deploy environment -p -v debug2 |& tee /etc/puppetlabs/r10k/logs/deploy.log
   ```

1. Check r10k deploy logs (from the host machine - outside the container)
   ```shell
   grep -i error custom/r10k/logs/deploy.log | grep -vE 'error_document|pe_license|title patterns that use procs are not supported|enc_error'
   ```

# More detailed examples
1. Reset the entire environment to start from scratch
   ```shell
   ./doit.sh reset
   ```
1. Remove containers and images, leave local customizations in place
   ```shell
   ./doit.sh clean
   ```
1. Start puppet server only
   ```shell
   ./doit.sh start puppet
   ```
1. Stop all containers
   ```shell
   ./doit.sh stop
   ```
1. Stop only a specific container
   ```shell
   ./doit.sh stop <container_name>
   ```
