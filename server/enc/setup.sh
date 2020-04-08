#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# make enc_adm runner script
/usr/bin/cp -f bin/puppetserver bin/enc_adm
sed -i -e 's/puppetserver/enc_adm/' bin/enc_adm

# make puppetserver reload script
/usr/bin/cp -f bin/puppetserver bin/hup
sed -i -e '/puppetserver/ d' bin/enc_adm
>>bin/hup echo "docker-compose exec puppet pkill -HUP -u puppet java"
ln -sf hup bin/reload

# install enc
docker cp server/enc/install.sh pupperware_puppet_1:/install_enc.sh
docker-compose exec puppet bash -c "/install_enc.sh |tee install_enc.log"
bin/hup

# initialize enc database
docker cp server/enc/tables.yaml pupperware_puppet_1:/etc/puppetlabs/local/enc/
bin/enc_adm --init
