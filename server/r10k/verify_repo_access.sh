#!/bin/bash

export GIT_SSH_COMMAND="ssh -o ConnectTimeout=1"

REPOS=( $(awk '$1=="remote:" {print $NF}' /etc/puppetlabs/r10k/r10k.yaml) )

for repo in "${REPOS[@]}"; do
    echo "Checking repo: '$repo' ..."
    git ls-remote "$repo" >/dev/null || {
        echo
        echo FATAL
        echo "Fix errors before running r10k"
        exit 1
    }
    echo OK
done
