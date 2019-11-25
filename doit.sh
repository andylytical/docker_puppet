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
    clean: (same as "stop" ... plus remove containers
    reset: (same as "clean" ... plus) remove images, volumes, networks

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


container_exists() {
    [[ $(docker ps -q -f name="$SRVR" | wc -l) -gt 0 ]]
}

server_is_running() {
    container_exists \
    && docker exec -it $SRVR /healthcheck.sh &>/dev/null
}


wait_for_server() {
    # Wait for server to start
    local RC
    container_exists || return $?
    server_is_running || {
        for i in {1..5} ; do
            [[ $i -eq 1 ]] && echo -n "(waiting for server to start... "
            echo -n "$i "
            sleep 10
            server_is_running
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
    mkdir -p "${VOLUME_ROOT}"/freeipa/data
    mkdir -p "${VOLUME_ROOT}"/freeipa/logs/httpd
    cp freeipa/ipa-server-install-options "${VOLUME_ROOT}"/freeipa/data
    mkdir -p "${CUSTOM_ROOT}"/enc
    mkdir -p "${CUSTOM_ROOT}"/r10k/logs
    touch "${CUSTOM_ROOT}"/enc/tables.yaml
    touch "${CUSTOM_ROOT}"/enc/pup_enc.db
}


do_enc() {
    # configure enc
    echo -n "Check ENC setup... "
    local restart_is_needed=0
    wait_for_server || return $?
    # setup enc; if needed
    docker exec -it $SRVR enc_adm -l &>/dev/null || { 
        docker exec -it $SRVR enc_adm --init
        docker exec -it $SRVR enc_adm --add --fqdn agent-centos-1.internal
        docker exec -it $SRVR enc_adm --add --fqdn agent-centos-2.internal
    }
    # configure node_terminus; if needed
    docker exec -it $SRVR puppet config print node_terminus --section master | grep -q -F exec || {
        docker exec -it $SRVR puppet config set node_terminus exec --section master
        restart_is_needed=1
    }
    # configure external_nodes; if needed
    local path="$PUP_CUSTOM_DIR/enc/admin.py"
    docker exec -it $SRVR puppet config print external_nodes --section master | grep -q -F "$path" || {
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
    # remove stopped and dead containers
    # but only those associated with this docker-compose file
    docker-compose rm -f
}


do_hard_cleanup() {
    local rm_dirs=()
    docker system prune -af
    # delete volume_root dir if not empty
    vol_dir=$(readlink -e "${VOLUME_ROOT}")
    echo "VOLDIR: '$vol_dir'"
    [[ $( stat -c %h "$vol_dir" ) -gt 2 ]] && rm_dirs+=( "$vol_dir" )
    # Clean up custom r10k dirs
    r10k_dir=$(readlink -e "${CUSTOM_ROOT}/r10k")
    for dn in cache logs; do
        tgt_dir="${r10k_dir}/$dn"
        if [[ -d "$tgt_dir" ]] ; then
            rm_dirs+=( "$tgt_dir" )
        fi
    done
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
