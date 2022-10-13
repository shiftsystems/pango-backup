#!/bin/bash
echo "dumping configs";
mkdir -p /tmp/vmconfigs
for i in $(virsh list --name); do
     echo dumping config for $i to /tmp/vmconfigs/$i.xml;
     virsh dumpxml --migratable $i > /tmp/vmconfigs/$i.xml;
     echo $i config has been dumped sucessfully
done

echo "backup configs"
borg create --progress --compression zstd,6 $BORG_URI::vm-configs /tmp/vmconfigs

echo "creating snapshots"
for i in $(virsh list --name); do
    qcow_path=$(virsh domblklist $i | grep qcow2 | awk '{print $2}')
    dev_name=$(virsh domblklist $i | grep qcow2 | awk '{print $1}')
    backup_path=$(echo "$qcow_path" | sed "s/.qcow2/.pangobackup.qcow2/g")
    echo "now creating snapshot for ${i} located at: $qcow_path"
    virsh snapshot-create-as --domain ${i} --name pangobackup.qcow2 --no-metadata --atomic --quiesce --disk-only --diskspec ${dev_name},snapshot=external
    echo "now backing up ${i}"
    borg create --progress --compression zstd,6 $BORG_URI::${i} ${qcow_path}
    echo "${i} has been backed up successfully"
    echo "now combining snapshot for ${i}"
    virsh blockcommit ${i} ${dev_name} --active --pivot
    echo "snapshot merged for ${i}";
    echo "removing snapshot for $i: $backup_path";
    rm -f $backup_path
    echo "$backup_path has been removed";
done
