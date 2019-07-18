# docker_puppet

# Quickstart
## Create Puppet server and agent
1. `./doit.sh start`

## Manually deploy environments with r10k
1. (optional) Modify r10k config file
   1. `vim custom/r10k/r10k.yaml`
1. Exec a bash shell in the running container
   1. `docker exec -it dockerpuppet_puppet_1 /bin/bash`
1. Run r10k to deploy environments
   1. `r10k deploy environment -p -v debug2 |& tee /etc/puppetlabs/r10k/logs/deploy.log`
1. Check r10k deploy logs
   1. NOTE: View logs from host machine (outside of the docker container)
   1. `grep -i error custom/r10k/logs/deploy.log | grep -vE 'error_document|pe_license|title patterns that use procs are not supported|enc_error'`

# More detailed examples
1. Reset the entire environment to start from scratch
   1. `.doit.sh reset`
1. Remove containers and images, leave local customizations in place
   1. `.doit.sh clean`
1. Create just the server
   1. `./doit.sh start puppet`
1. Stop containers
   1. `./doit.sh stop`
1. Stop only a specific container
   1. `./doit.sh stop <container_name>`

