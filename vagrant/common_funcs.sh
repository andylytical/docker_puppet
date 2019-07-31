#!/bin/bash


die() {
    echo "ERROR (${BASH_SOURCE[1]} [${BASH_LINENO[0]}] ${FUNCNAME[1]}) $*" 1>&2
    exit 99
}


warn() {
    echo "WARN (${BASH_SOURCE[1]} [${BASH_LINENO[0]}] ${FUNCNAME[1]}) $*" 1>&2
}


log() {
    [[ $VERBOSE -ne 1 ]] && return
    echo "INFO (${BASH_SOURCE[1]} [${BASH_LINENO[0]}] ${FUNCNAME[1]}) $*" 1>&2
}


debug() {
    [[ $DEBUG -ne 1 ]] && return
    echo "DEBUG (${BASH_SOURCE[1]} [${BASH_LINENO[0]}] ${FUNCNAME[1]}) $*" 1>&2
}


dumpvars() {
    [[ $VERBOSE -eq 1 ]] || return 0
    for a in $*; do
        printf "%s=%s\n" $a ${!a} 1>&2
    done
}


ask_yes_no() {
    [[ "$ALWAYSYES" -eq 1 ]] && return 0
    local rv=1
    local msg="Is this ok?"
    [[ -n "$1" ]] && msg="$1"
    echo "$msg"
    select yn in "Yes" "No"; do
        case "$yn" in
            Yes) rv=0;;
            No ) rv=1;;
        esac
        break
    done
    return "$rv"
}


continue_or_exit() {
    [[ "$ALWAYSYES" -eq 1 ]] && return 0
    [[ -n "$1" ]] && echo "$1"
    shift
    local pause=60
    [[ -n "${1//[^0-9]/}" ]] && pause="${1//[^0-9]/}"
    echo "Continue?"
    local yn
    select yn in "Yes" "No"; do
        case $yn in
            Yes) return 0;;
            No ) exit 1;;
        esac
    done
}


assert_root() {
    log "enter..."
    [[ $EUID -eq 0 ]] || die 'Must be root'
}


install_pkgs() {
    log "enter..."
    [[ $# -gt 0 ]] || die "empty pkg list"
    yum install -y "$@" || die "yum install returned non-zero"
}


ip_increment() {
    [[ $DEBUG -eq 1 ]] && set -x
    ipstart="$1"
    incr="$2"
    echo "$ipstart $incr" \
    | awk -v "incr=$incr" -F. '{ printf( "%d.%d.%d.%d", $1, $2, $3, $4 + incr ) }'
}
