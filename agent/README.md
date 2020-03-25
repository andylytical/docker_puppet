# Puppet Agent in Docker

Assumptions:
- Running only ONE agent container
- Using CentOS agent
- All commands below are run from the `~/pupperware` directory

## Enable agent container
- Add `docker-compose.agent.yml` to `COMPOSE_FILE` (in `.env`)
- `cat agent/env >> .env`
- Review .env settings
  - `vim .env`

## Start agent container
```shell
docker-compose up -d agent-centos
```

## (optional) Set a custom agent certname
```shell
docker-compose exec agent-centos puppet config set certname NEW-FQDN
```
Note: if agent has run before, either delete the existing container and make
a new one or delete the puppet certs on both agent and master.

## (one time) Add the node to the puppet ENC database
```shell
bin/enc_adm --add --fqdn $(docker-compose exec agent-centos hostname | tr -cd '\40-\176')
```

## Run puppet agent
```shell
docker-compose exec agent-centos puppet agent -t
```
