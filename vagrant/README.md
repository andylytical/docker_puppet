# End-to-End Puppet Testing with Vagrant
Better end-to-end testing from a VM 
(as compared to running an agent in a docker container.)

### Requirements
- [vagrant](https://www.vagrantup.com/docs/installation/)
- `vagrant plugin install vagrant-scp` (?actually needed?)
- [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads)

### Important Notes:
- For all commands below, it is assumed you are in the `pupperware/vagrant`
  directory.
  ```shell
  cd ~/pupperware/vagrant
  ```

### Create and Start a VM
The VM named `agent` is pre-defined and will build a VM based on CentOS
and then install puppet agent.
```shell
vim conf.yaml #change the agent hostname (the domain must match what was set in ~/pupperware/.env)
vagrant up agent
```

### Get the agent hostname and add it to pupperware ENC
```shell
~/pupperware/bin/enc_adm --add --fqdn $(vagrant ssh agent -c 'hostname' | tr -cd "[:print:]")
~/pupperware/bin/enc_adm -l
```

### Run puppet agent
```shell
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
   ~/pupperware/bin/puppetserver ca clean --certname HOSTNAME_FROM_ABOVE
   ```
* Remove all local Vagrant box images
  ```shell
  vagrant box list | cut -d' ' -f1 | sort -u | xargs -r -n1 -- vagrant box remove --all
  ```
