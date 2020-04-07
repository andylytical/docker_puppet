#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# make custom r10k runner (in the container)
docker cp server/r10k/install.sh pupperware_puppet_1:/r10k_install.sh
docker-compose exec puppet bash /r10k_install.sh

# configure r10k
docker cp server/r10k/r10k.yaml pupperware_puppet_1:/etc/puppetlabs/r10k/r10k.yaml

# make r10k runner script (outside docker)
/usr/bin/cp -f bin/puppetserver bin/r10k
#sed -i -e 's/puppetserver/\/r10k/' bin/r10k
sed -i -e '/puppetserver/ d' bin/r10k
>>bin/r10k echo "date; time docker-compose exec puppet /r10k \"\$@\""
>>bin/r10k echo "date"

# make verify repos script
/usr/bin/cp -f bin/puppetserver bin/verify_repo_access
sed -i -e '/puppetserver/ d' bin/verify_repo_access
>>bin/verify_repo_access echo -n "docker-compose exec puppet bash -c '"
>>bin/verify_repo_access echo -n 'awk "\$1==\"remote:\"{print \$NF}" /etc/puppetlabs/r10k/r10k.yaml | xargs -n1 git ls-remote'
>>bin/verify_repo_access echo "'"
