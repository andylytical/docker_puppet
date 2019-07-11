# docker_puppet

# Create Puppet Standalone server
1. `docker-compose up --build -d`

# R10K
## Manually deploy environments
1. Exec a bash shell in the running container
   1. `docker exec -it dockerpuppet_puppetserver_1 /bin/bash`
1. Run r10k to deploy environments
   1. `r10k deploy environment -p -v debug2 |& tee /etc/puppetlabs/r10k/logs/deploy.log`

## Check r10k deploy log
View logs from host machine (outside of the docker container)
1. `grep -i error custom/r10k/logs/deploy.log | grep -vE 'error_document|pe_license|title patterns that use procs are not supported|enc_error'`
