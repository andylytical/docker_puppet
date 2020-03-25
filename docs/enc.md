# Puppet ENC

## Help
- `bin/enc_adm -h`
- `bin/enc_adm --help`

## Listing nodes
- `bin/enc_adm -l`
- `bin/enc_adm -l fqdn1 fqdn2`
- `bin/enc_adm -l patrn` #will show all nodes that match 'patrn' anywhere in
  the nodename

## Adding nodes
- Add a node using default values in tables.yaml
  ```shell
  bin/enc_adm --add FQDN
  ```
- Add a node changing a specific parameter
  ```shell
  bin/enc_adm --add --environment env1 --site testsite FQDN
  ```
- Add one or multiple nodes using a yaml file
  ```shell
  bin/enc_adm --mkyaml >nodes.yaml
  # edit the yaml file
  bin/enc_adm --add --yaml nodes.yaml
  ```

## Change environment for a node (to match a branch in the puppet control repo)
- `bin/enc_adm --topic git_branch_name FQDN`
- `bin/enc_adm --ch --environment git_branch_name FQDN`

## See the actual yaml response to the puppetserver ENC request
```shell
bin/enc_adm FQDN
```
