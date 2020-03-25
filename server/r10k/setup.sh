#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# make custom r10k runner (in the container)
docker cp server/r10k/install.sh pupperware_puppet_1:/install_r10k.sh
docker-compose exec puppet bash -c '/install_r10k.sh |tee /install_r10k.log'

# configure r10k
docker cp server/r10k/r10k.yaml pupperware_puppet_1:/etc/puppetlabs/r10k/r10k.yaml

# make r10k runner script (outside docker)
/usr/bin/cp -f bin/puppetserver bin/r10k
#sed -i -e 's/puppetserver/\/r10k/' bin/r10k
sed -i -e '/puppetserver/ d' bin/r10k
>>bin/r10k echo "date; time docker-compose exec puppet /r10k \"\$@\""
>>bin/r10k echo "date"

# install custom verify script
docker cp server/r10k/verify_repo_access.sh pupperware_puppet_1:/verify_repo_access.sh
docker-compose exec puppet chmod +x /verify_repo_access.sh
/usr/bin/cp -f bin/puppetserver bin/verify_repo_access
sed -i -e 's/puppetserver/\/verify_repo_access.sh/' bin/verify_repo_access
