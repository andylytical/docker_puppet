#!/bin/bash

set -x

DEFAULT=~/pupperware
cd "${PUPPERWARE:-$DEFAULT}" || {
    echo "Can't find pupperware dir at: $DEFAULT OR \$PUPPERWARE" 1>&2
    exit 1
}

# custom r10k runner inside the container
docker cp -L server/r10k/install.sh pupperware_puppet_1:/install_r10k.sh
docker-compose exec puppet bash -c '/install_r10k.sh |tee /install_r10k.log'
docker-compose exec puppet bash -c 'ln -s /etc/puppetlabs/r10k/r10k.sh /r10k'

# configure r10k
docker cp -L server/r10k/r10k.yaml pupperware_puppet_1:/etc/puppetlabs/r10k/r10k.yaml

# r10k runner script outside the container
tgt=bin/r10k
/bin/cp -f bin/puppetserver $tgt
sed -i -e '/puppetserver/ d' $tgt
>>$tgt echo 'echo "R10K Start $(date)"'
>>$tgt echo "docker-compose exec puppet /r10k \"\$@\""
>>$tgt echo 'echo'
>>$tgt echo 'echo "ELAPSED: $SECONDS (seconds)"'

# Log viewer for r10k
tgt=bin/r10k_log
/bin/cp -f bin/puppetserver $tgt
sed -i -e '/puppetserver/ d' $tgt
>>$tgt cat <<ENDHERE
tmpfn=\$(mktemp)
>\$tmpfn docker-compose exec puppet bash -c 'cat /var/log/r10k/\$(ls /var/log/r10k | tail -1)'
less \$tmpfn
rm \$tmpfn
ENDHERE


# Verify r10k repo access
docker cp -L server/r10k/verify_repo_access.sh pupperware_puppet_1:/verify_repo_access.sh
docker-compose exec puppet chmod +x /verify_repo_access.sh
/bin/cp -f bin/puppetserver bin/verify_repo_access
sed -i -e 's/puppetserver/\/verify_repo_access.sh/' bin/verify_repo_access
