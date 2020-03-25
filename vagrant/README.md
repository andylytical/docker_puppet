# End-to-End Puppet Testing with Vagrant
Some configurations don't make sense in a docker container, thus complete testing is
done from a VM.

### Requirements
- [vagrant](https://www.vagrantup.com/docs/installation/)
- `vagrant plugin install vagrant-scp` (?actually needed?)
- [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads)


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
  * Note: Must also clean up the current cert on the puppet master:
   ```shell
   # from a bash shell in the puppet master container:
   puppetserver ca clean --certname agent-centos-2.test.local
   ```
* Remove all local Vagrant box images
  ```shell
  vagrant box list | cut -d' ' -f1 | sort -u | xargs -r -n1 -- vagrant box remove --all
  ```
