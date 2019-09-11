#!/bin/bash

source .env

# Puppet server container name
SRVR="${PUPPET_SERVER_CONTAINER_NAME}"


usage() {
    cat <<ENDHERE

Usage: $0 [options] action

Options:
    -h   Print this help

Actions:
    start: Start specified container (or all containers if none specified)
     stop: Stop the specified container (or all containers if none specified)
    clean: (same as "stop", plus) remove containers, images and networks
    reset: (same as "clean", plus) remove locally stored content from the containers

ENDHERE
}


err() {
    echo "$*" 1>&2
}


ask_yes_no() {
    local rv=1
    local msg="Is this ok?"
    [[ -n "$1" ]] && msg="$1"
    echo "$msg"
    select yn in "Yes" "No"; do
        case $yn in
            Yes) rv=0;;
            No ) rv=1;;
        esac
        break
    done
    return $rv
}


is_server_running() {
    docker exec -it $SRVR /healthcheck.sh &>/dev/null
}


wait_for_server() {
    # Wait for server to start
    local RC
    is_server_running || {
        for i in {1..5} ; do
            [[ $i -eq 1 ]] && echo -n "(waiting for server to start... "
            echo -n "$i "
            sleep 10
            is_server_running
            RC=$?
            [[ $RC -eq 0 ]] && break
        done
        [[ $RC -eq 0 ]] && echo -n "OK) " || echo -n "ERR) "
    }
    return $RC
}


restart_server() {
    wait_for_server \
    && docker exec -it $SRVR pkill -HUP -u puppet java
}


do_setup() {
    mkdir -p "${CUSTOM_ROOT}"/custom/r10k/logs
    mkdir -p "${CUSTOM_ROOT}"/custom/enc
    touch "${CUSTOM_ROOT}"/custom/enc/tables.yaml
    touch "${CUSTOM_ROOT}"/custom/enc/pup_enc.db
}


do_enc() {
    # configure enc
    echo -n "Check ENC setup... "
    local restart_is_needed=0
    # setup enc; if needed
    docker exec -it $SRVR enc_adm -l &>/dev/null || { 
        docker exec -it $SRVR enc_adm --init
        docker exec -it $SRVR enc_adm --add --fqdn agent-centos-1.internal
        docker exec -it $SRVR enc_adm --add --fqdn agent-centos-2.internal
    }
    # configure node_terminus; if needed
    docker exec -it $SRVR puppet config print node_terminus --section master | grep -q -F exec || {
        wait_for_server
        docker exec -it $SRVR puppet config set node_terminus exec --section master
        restart_is_needed=1
    }
    # configure external_nodes; if needed
    local path="$PUP_CUSTOM_DIR/enc/admin.py"
    docker exec -it $SRVR puppet config print external_nodes --section master | grep -q -F "$path" || {
        wait_for_server
        docker exec -it $SRVR puppet config set external_nodes "$path" --section master
        restart_is_needed=1
    }
    # restart server
    if [[ $restart_is_needed -eq 1 ]]; then
        restart_server
    fi
    echo "OK"
}


do_start() {
    do_setup
    docker-compose up -d --build "$@"
    do_enc
}


do_stop() {
    docker-compose stop "$@"
}


do_cleanup() {
#    "...compose down ..." throws errors if images,containers,networks are already removed
#    docker-compose down --rmi all --remove-orphans

    # list stopped and dead containers
    tmpfn_images=$(mktemp)
    tmpfn_containers=$(mktemp)
    docker ps -a -f status=exited -f status=dead --format "{{.ID}} {{.Image}}" \
    | tee >( awk '{print $1}' > $tmpfn_containers ) \
          >( awk '{print $2}' > $tmpfn_images ) \
          >/dev/null

    # rm containers
    xargs -a $tmpfn_containers -r docker rm -f

    # Remove images
    xargs -a $tmpfn_images -r docker rmi

    # remove extraneous networks
    docker network prune --force
}


do_hard_cleanup() {
    rm_dirs=()
    vol_dir=$(readlink -e "${VOLUME_ROOT}"/volumes)
    if [[ -d "$vol_dir"/code ]] ; then
        rm_dirs+=( "$vol_dir" )
    fi
    r10k_dir=$(readlink -e "${CUSTOM_ROOT}"/custom/r10k)
    cache_dir="${r10k_dir}"/cache
    if [[ -d "$cache_dir" ]] ; then
        rm_dirs+=( "$cache_dir" )
    fi
    log_dir="${r10k_dir}"/logs
    if [[ -d "$log_dir" ]] ; then
        rm_dirs+=( "$log_dir" )
    fi
    if [[ ${#rm_dirs[@]} -gt 0 ]] ; then
        echo
        echo "* * * WARNING * * *"
        echo "About to recursively delete directories:"
        for d in "${rm_dirs[@]}"; do
            echo "  $d"
        done
        echo
        ask_yes_no \
        && sudo -- rm -rf "${rm_dirs[@]}"
    fi
#    for fn in "${CUSTOM_ROOT}"/custom/enc/pup_enc.db ; do
#        [[ -f "$fn" ]] \
#        && rm "$fn"
#    done
}


ENDWHILE=0
while [[ $# -gt 0 ]] && [[ $ENDWHILE -eq 0 ]] ; do
  case $1 in
    -h) usage; exit 0;;
    --) ENDWHILE=1;;
    -*) echo "Invalid option '$1'"; exit 1;;
     *) ENDWHILE=1; break;;
  esac
  shift
done

[[ $# -lt 1 ]] && {
	usage
	exit
}
action="$1"
shift

case $action in
    clean)
        do_stop "$@"
        do_cleanup
        ;;
    enc)
        do_enc
        ;;
    reset)
        do_stop
        do_cleanup
        do_hard_cleanup
        ;;
    setup)
        do_setup
        ;;
    start)
        do_start "$@"
        ;;
    stop)
        do_stop "$@"
        ;;
    *)
        err "Unknown action: '$action'"
        usage
        ;;
esac
