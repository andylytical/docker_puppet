# End-to-End Puppet Testing with Vagrant
Some configurations don't make sense in a docker container, thus complete testing is
done from a VM.


### Create the custom virtualbox image
Needed only once. Note also, this will always rebuild a new image and wipe out the old one.
```shell
./mk-custom-image.sh
```

### Add test VM to puppetserver ENC
(needed only once)
```shell
   pushd ..
   docker exec -it server enc_adm --add --fqdn agent-centos-2.internal
   popd
```

### Run puppet agent on a test VM
```shell
   vagrant up agent
   vagrant ssh agent
   sudo su -
   puppet agent -t
```

# Miscellaneous
* See `conf.yaml` to adjust settings of the VM guest
* Delete existing VM guests
  ```shell
  vagrant destroy --force --parallel
  ```
** Note: Must also clean up old certs on the puppet master:
   ```shell
   puppet cert clean agent-centos-2.internal
   pkill -HUP -u puppet java
   ```
