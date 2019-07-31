# End-to-End Puppet Testing with Vagrant
Some configurations don't make sense in a docker container, thus complete testing is
done from a VM.


### Create the custom virtualbox image
Needed only once. Note also, this will always rebuild a new image and wipe out the old one.
1. `./mk-custom-image.sh`

### Start a test VM
1. `vagrant up agent`

### Run puppet agent in the VM
1. `vagrant ssh agent01`
   1. `sudo su -`
   1. `puppet agent -t`

# Miscellaneous
* See `conf.yaml` to adjust settings of the VM guest
