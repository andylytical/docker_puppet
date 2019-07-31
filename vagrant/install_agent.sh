#!/bin/bash

BASEPATH="${PUP_INSTALL_BASEPATH:-/root/puppet_deployment}"
INCLUDES=( \
    $BASEPATH/common_funcs.sh
)

for f in "${INCLUDES[@]}"; do
    [[ -f "$f" ]] || { echo "Cant include file '$f'"; exit 1
    }
    source  "$f"
done

# Global settings
PUPPET=/opt/puppetlabs/bin/puppet
HOSTNAME="${PUP_INSTALL_HOSTNAME:-$(hostname)}"
OS_NAME="${PUP_INSTALL_OS_NAME:-el}"
OS_VER="${PUP_INSTALL_OS_VER:-7}"
REQUIRED_PKGS=( bind-utils lsof )

# Command line option defaults
VERBOSE="${PUP_INSTALL_VERBOSE:-0}"
DEBUG="${PUP_INSTALL_DEBUG:-0}"
FORCE="${PUPINSTALLFORCE:-0}"
PUP_VERSION="${PUP_INSTALL_VERSION:-5}"
AGENT_CERTNAME="$PUP_AGENT_CERTNAME"        #allow override hostname
AGENT_PUPMASTER="${PUP_MASTER:-10.0.2.2}"  #ip or valid DNS hostname of pupmaster


###
# Process Command Line
###
while :; do
    case "$1" in
        -h|-\?|--help)
            echo "Usage: ${0##*/} [OPTIONS]"
            echo "Options:"
            echo "    -A <AgentCertname>    (override certname, defaults to hostname)"
            echo "    -d                    (enable debug mode)"
            echo "    -F                    (Force install. Install over the top of existing setup)"
            echo "    -P <Puppet Master IP> (IP or hostname of puppet master, used only for agent build type)"
            echo "    -v                    (enable verbose mode)"
            exit
            ;;
        -A) AGENT_CERTNAME="$2"
            shift
            ;;
        -d) VERBOSE=1
            DEBUG=1
            ;;
        -F) FORCE=1
            ;;
        -P) AGENT_PUPMASTER="$2"
            shift
            ;;
        -v) VERBOSE=1
            ;;
        --) shift
            break
            ;;
        -?*)
            die "Invalid option: $1"
            ;;
        *)  break
            ;;
    esac
    shift
done



###
# Functions
###

assert_valid_options() {
    [[ -n "$AGENT_PUPMASTER" ]] || die 'Missing Pup Master IP or hostname'
}


clean_old() {
    log "enter..."
    [[ "$DEBUG" -gt 0 ]] && set -x
    [[ "$FORCE" -lt 1 ]] && return 0  # Do nothing if force is not set
    # remove puppet rpm packages
    yum list installed | awk '/puppet/ {print $1}' \
    | xargs -r yum -y remove
    # delete puppet install locations
    find /etc/puppetlabs -delete
    find /opt/puppetlabs -delete
    find /var/cache/r10k -delete
    find /etc/yum.repos.d/ -type f -name 'puppet*' -delete
}


install_required_pkgs() {
    log "enter..."
    [[ "$DEBUG" -gt 0 ]] && set -x
    local pkg_list=( "${REQUIRED_PKGS[@]}" )
    [[ ${#REQUIRED_PKGS[@]} -gt 0 ]] && return
    install_pkgs "${REQUIRED_PKGS[@]}" || die "error during pkg install"
}


install_puppet() {
    log "enter..."
    [[ "$DEBUG" -gt 0 ]] && set -x
    #Install yum repo
    local YUM_REPO_URL=https://yum.puppet.com
    case "$PUP_VERSION" in
        5|6)
            local rpm_fn=puppet${PUP_VERSION}-release-${OS_NAME}-${OS_VER}.noarch.rpm
            local path=puppet${PUP_VERSION}
            YUM_REPO_URL=$YUM_REPO_URL/$path/$rpm_fn
            ;;
        *)
            die "Unknown puppet version: '$PUP_VERSION'"
            ;;
    esac
    ls /etc/yum.repos.d/puppet*.repo &>/dev/null \
    || install_pkgs $YUM_REPO_URL
    ls /etc/yum.repos.d/puppet*.repo &>/dev/null \
    || die "Failed to install Yum repo file"

    #Install puppet agent
    install_pkgs puppet-agent
}


agent_config() {
    log "enter..."
    [[ "$DEBUG" -gt 0 ]] && set -x
    $PUPPET config set --section agent server "$AGENT_PUPMASTER"
    if [[ -n "$AGENT_CERTNAME" ]] ; then
        $PUPPET config set certname "$AGENT_CERTNAME"
    fi
}


agent_run() {
    log "enter..."
    [[ "$DEBUG" -gt 0 ]] && set -x
    $PUPPET agent --test
}


####################################################


# Always perform these steps
assert_root
assert_valid_options
clean_old
install_required_pkgs
install_puppet
agent_config
#agent_run
