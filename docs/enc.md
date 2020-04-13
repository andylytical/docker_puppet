# Puppet ENC

## Help
- `~/pupperware/bin/enc_adm -h`
- `~/pupperware/bin/enc_adm --help`

## Listing nodes
- `~/pupperware/bin/enc_adm -l`
- `~/pupperware/bin/enc_adm -l fqdn1 fqdn2`
- `~/pupperware/bin/enc_adm -l patrn` #will show all nodes that match 'patrn' anywhere in
  the nodename

## Adding nodes
- Add a node using default values in tables.yaml
  ```shell
  ~/pupperware/bin/enc_adm --add --fqdn FQDN
  ```
- Add a node changing a specific parameter
  ```shell
  ~/pupperware/bin/enc_adm --add --environment env1 --site testsite --fqdn FQDN
  ```
- Add one or multiple nodes using a yaml file
  ```shell
  ~/pupperware/bin/enc_adm --mkyaml >nodes.yaml
  vim nodes.yaml
  ~/pupperware/bin/enc_adm --add --yaml nodes.yaml
  ```

## Change environment for a node (to match a branch in the puppet control repo)
- `~/pupperware/bin/enc_adm --topic git_branch_name FQDN`
- `~/pupperware/bin/enc_adm --ch --environment git_branch_name FQDN`

## See the actual yaml response to the puppetserver ENC request
```shell
~/pupperware/bin/enc_adm FQDN
```
