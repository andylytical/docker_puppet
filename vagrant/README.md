# End-to-End Puppet Testing with Vagrant
Some configurations don't make sense in a docker container, thus complete testing is
done from a VM.


### Create the custom virtualbox image
Needed only once. Note also, this will always rebuild a new image and wipe out the old one.
Use command `vagrant box list` to see image status.
```shell
./mk-custom-image.sh
```


### Run puppet agent on a test VM
```shell
   vagrant up agent
   vagrant ssh agent -c 'sudo /opt/puppetlabs/bin/puppet agent -t'
```

# Miscellaneous
* See `conf.yaml` to adjust settings of the VM guest
* Delete existing VM guests
  ```shell
  vagrant destroy --force --parallel
  ```
** Note: Must also clean up old certs on the puppet master:
   ```shell
   # use docker-compose command to exec a bash shell on the puppet master, then do:
   puppet cert clean agent-centos-2.internal
   pkill -HUP -u puppet java
   ```
