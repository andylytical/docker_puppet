#!/bin/bash

source .env


usage() {
    cat <<ENDHERE

Usage: $0 [options] action

Options:
    -h   Print this help

Action:
    One of "setup", "start", "stop", "reset"

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


do_setup() {
    mkdir -p "${CUSTOM_ROOT}"/custom/{enc,r10k}
    touch "${CUSTOM_ROOT}"/custom/enc/tables.yaml
    touch "${CUSTOM_ROOT}"/custom/enc/pup_enc.db
}


do_start() {
    do_setup
    docker-compose up -d "$@"
}


do_stop() {
    docker-compose stop "$@"
}


do_cleanup() {
    # remove containers
    docker ps -a --format "{{.ID}} {{.Names}}" \
    | awk '/dockerpup/{print $1}' \
    | xargs -r docker rm -f

    # Remove puppetservice images
    docker images --format "{{.ID}} {{.Repository}}" \
    | awk '/dockerpup/ {print $1}' \
    | xargs -r docker rmi
}


do_hard_cleanup() {
    vol_dir=$(readlink -e "${VOLUME_ROOT}"/volumes)
    if [[ -d "$vol_dir"/code ]] ; then
        echo
        echo "* * * WARNING * * *"
        echo "About to recursively delete: '$vol_dir'"
        echo
        ask_yes_no \
        && sudo -- rm -rf "$vol_dir"
    fi
}


ENDWHILE=0
while [[ $# -gt 0 ]] && [[ $ENDWHILE -eq 0 ]] ; do
  case $1 in
    -h) usage;;
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
    setup)
        do_setup
        ;;
    start)
        do_start "$@"
        ;;
    stop)
        do_stop "$@"
        ;;
    clean)
        do_stop
        do_cleanup
        ;;
    reset)
        do_stop
        do_cleanup
        do_hard_cleanup
        ;;
    *)
        err "Unknown action: '$action'"
        usage
        ;;
esac
