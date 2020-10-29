#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# make enc_adm runner script
/bin/cp -f bin/puppetserver bin/enc_adm
sed -i -e 's|puppetserver|/etc/puppetlabs/enc/admin.py|' bin/enc_adm

# make puppetserver reload script
/bin/cp -f bin/puppetserver bin/hup
sed -i -e '/puppetserver/ d' bin/hup
>>bin/hup echo "docker-compose exec puppet pkill -HUP -u puppet java"
ln -sf hup bin/reload

# install enc
docker cp -L server/enc/tables.yaml pupperware_puppet_1:/etc/puppetlabs/enc/
docker cp -L server/enc/config.ini pupperware_puppet_1:/etc/puppetlabs/enc/
docker cp -L server/enc/install.sh pupperware_puppet_1:/install_enc.sh
docker-compose exec puppet bash -c "/install_enc.sh 2>&1 | tee install_enc.log"
bin/hup

# initialize enc database
bin/enc_adm --init
