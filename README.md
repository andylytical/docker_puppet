# docker_puppet

# Quickstart
## Create Puppet server and agent
1. `./doit.sh start`

## Manually deploy environments with r10k
1. Exec a bash shell in the running container
   1. `docker exec -it dockerpuppet_puppetserver_1 /bin/bash`
1. Run r10k to deploy environments
   1. `r10k deploy environment -p -v debug2 |& tee /etc/puppetlabs/r10k/logs/deploy.log`
1. Check r10k deploy logs
   1. NOTE: View logs from host machine (outside of the docker container)
   1. `grep -i error custom/r10k/logs/deploy.log | grep -vE 'error_document|pe_license|title patterns that use procs are not supported|enc_error'`

# Delete all docker containers / images and start from scratch
1. Stop and remove containers
   1. `docker-compose stop`
   1. `docker ps -a --format "{{.ID}} {{.Names}}" | awk '/dockerpup/{print $1}' | xargs -r docker rm -f`
1. Remove puppetservice images
   1. `docker images --format "{{.ID}} {{.Repository}}" | awk '/dockerpup/ {print $1}' | xargs -r docker rmi`
1. Remove local, mapped volumes (optional)
   1. `sudo -- rm -rf $(pwd)/volumes`
1. Re-deploy puppet standalone server
   1. `docker-compose up -d`

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

