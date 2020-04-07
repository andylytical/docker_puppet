#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# install enc
docker cp server/enc/install.sh pupperware_puppet_1:/enc_install.sh
docker-compose exec puppet bash /enc_install.sh

# initialize enc database
docker cp server/enc/tables.yaml pupperware_puppet_1:/etc/puppetlabs/local/enc/
docker-compose exec puppet enc_adm --init

# make enc_adm runner script
/usr/bin/cp -f bin/puppetserver bin/enc_adm
sed -i -e 's/puppetserver/enc_adm/' bin/enc_adm
