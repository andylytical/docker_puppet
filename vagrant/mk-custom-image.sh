#!/bin/bash

IMG=newimage
BOX_NAME=centos-custom
FILE_NAME=${BOX_NAME}.box

set -x

vagrant destroy --force "${IMG}"

vagrant up "${IMG}"

ls "${FILE_NAME}" | xargs -r -- rm

vagrant package "${IMG}" --output "${FILE_NAME}"

vagrant box add -f --name "${BOX_NAME}" "${FILE_NAME}"

vagrant destroy --force "${IMG}"
