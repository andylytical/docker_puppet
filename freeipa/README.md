# FreeIPA

NOTE - UNTESTED / UNSUPPORTED - Needs verification since #3 (19Mar2020)

## Enable freeipa
- Add `docker-compose.freeipa.yml` to `COMPOSE_FILE` (in `.env`)

## Start FreeIPA by itself
```shell
docker-compose up -d freeipa
```

## Watch freeipa logs
```shell
docker-compose logs -f freeipa
```
Use `Ctl-c` to exit log viewer
