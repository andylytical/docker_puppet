#!/bin/bash

set -x

URL_BASE="https://raw.githubusercontent.com/andylytical/docker_puppet"
URL_RESET="${URL_BASE}/${QS_GIT_BRANCH:-master}/server/tools/reset.sh"
URL_EXTRAS="${URL_BASE}/${QS_GIT_BRANCH:-master}/server/tools/extras.sh"

cd
curl "$RESET" | bash

cd ~/pupperware || {
    echo "Can't find ~/pupperware dir. Did something break up above?" >&2
    exit 1
}

all_services_up() {
    local _svc_count=$(docker-compose ps --services | wc -l)
    local _ok_count=$(docker-compose ps -a | tail -n+3 | grep -F 'Up (healthy)'| wc -l)
    [[ $_ok_count -eq $_svc_count ]]
}


for i in $(seq 5); do
    all_services_up && break
    sleep 10
done
all_services_up || { 
    echo 'SERVICES NOT STARTED'
    exit 1
}

# Install extras
curl "$URL_EXTRAS" | bash

# Continue setup steps
export COMPOSE_INTERACTIVE_NO_CLI=1
server/enc/setup.sh \
&& server/r10k/setup.sh
