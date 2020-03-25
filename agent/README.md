# Puppet Agent in Docker

Assumptions:
- Running only ONE agent container
- Using CentOS agent

## Enable agent container
- Add `docker-compose.agent.yml` to `COMPOSE_FILE` (in `.env`)

## Start agent container (by itself)
```shell
docker-compose up -d agent-centos
```

## (optional) Set a custom agent certname
```shell
docker-compose exec agent-centos puppet config set certname NEW-FQDN
```
Note: if agent has run before, either delete the existing container and make
a new one or delete the puppet certs on both agent and master.

## (one time, at least) Add the node to the puppet ENC database
See: docs/enc.md

## Run puppet agent
```shell
docker-compose exec agent-centos puppet agent -t
```
