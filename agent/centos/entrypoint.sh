#!/bin/bash

service=puppet
port=8140

while ! nc -z "$service" "$port"
do
  echo "(entrypoint) Waiting for $service:$port"
  sleep 1
done

# may want to do a check for existing certname and move aside if doesn't match
puppet config set certname $PUPPET_AGENT_CERTNAME

puppet agent -t

exec "$@"
