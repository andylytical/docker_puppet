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
