# Pango backup
A way to automate VM backups with Ansible systemd, and borg backup

## Deploy
1. initalize your borg backup repo
2. Make sure your password is stored securely and you have multiple ways to access the remote repo. 
2. clone the repo
3. copy the inventory outside the folder
4. edit the inventory so it contains  your info
5. run the playbook ```ansible-playbook -i <path to inventory> pango-backup.yml --ask-become-pass```

## Viewing your backups

### Using Vorta
* [Install Vorta](https://vorta.borgbase.com/install/)
* [Setup Remote repo](https://vorta.borgbase.com/usage/remote/)
* [Setup Local repo](https://vorta.borgbase.com/usage/local/)

### Using the CLI
1. add borg URI env varible `export BORG_URI=BORG_URI_FROM_ANSIBLE_INVENTORY`
2. add borg passphrase env variable `export BORG_PASSPHRASE=BORG_PASSPHRASE_FROM_ANSIBLE_INVENTORY`
3. list the borg repo `borg list $BORG_URI`
  * for easier viewing pipe the output to less `borg list $BORG_URI | less`

## Restoring your VMs


### Restoring to another box
1. add borg URI env varible `export BORG_URI=BORG_URI_FROM_ANSIBLE_INVENTORY`
2. add borg passphrase env variable `export BORG_PASSPHRASE=BORG_PASSPHRASE_FROM_ANSIBLE_INVENTORY`
3. mount the borg repo as your user. `borg mount -o uid=$UID,umask=077 $BORG_URI::<VM_NAME>-<backup timestamp> <mount path>`
4. copy the qcow2 file from `<mount_path>/<original path>`
5. reconfigure the vm either by using an XML file in a vm-configs archive or by recreating the vm using virt-manager or cockpit-machines. 


### Restoring to the same box
should be the same as to another box but shutdown the existing vm and move the qcow2 file someowhere else or delete it first.
