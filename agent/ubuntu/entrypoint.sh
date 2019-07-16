#!/bin/bash

service=puppet
port=8140

while ! nc -z "$service" "$port"
do
  echo "(entrypoint) Waiting for $service:$port"
  sleep 1
done

exec "$@"
