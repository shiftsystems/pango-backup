# Pango backup
A way to automate VM backups with Ansible systemd, and borg backup

## Deploy
1. initalize your borg backup repo
2. clone the repo
3. copy the inventory outside the folder
4. edit the inventory so it contains  your info
5. run the playbook ```ansible-playbook -i <path to inventory> pango-backup.yml --ask-become-pass```

## Restoring your VMs
TODO but data should be available in the [borg base docs](https://docs.borgbase.com/restore/borg/cli/)
