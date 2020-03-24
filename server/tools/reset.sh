#!/bin/bash

QS_URL=https://raw.githubusercontent.com/andylytical/quickstart/master/quickstart.sh

set -x

DIR="${PUPPERWARE:-$HOME/pupperware}"
PDIR="$(readlink -e "$DIR")"
[[ -d "$PDIR" ]] || {
    echo "Can't find pupperware dir" >&2
    exit 1
}

cd "$PDIR" \
&& docker-compose stop \
&& docker system prune -af --volumes \
&& cd "$PDIR"/.. \
&& rm -rf "$PDIR" \
&& git clone https://github.com/puppetlabs/pupperware \
&& cd pupperware \
&& export QS_REPO=https://github.com/andylytical/docker_puppet \
&& curl $QS_URL | bash \
&& cd "$PDIR" \
&& docker-compose up -d \
