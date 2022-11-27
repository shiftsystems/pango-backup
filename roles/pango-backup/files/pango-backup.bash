#!/bin/bash
echo "dumping configs";
mkdir -p /tmp/vmconfigs
for i in $(virsh list --name); do
     echo dumping config for $i to /tmp/vmconfigs/$i.xml;
     virsh dumpxml --migratable $i > /tmp/vmconfigs/$i.xml;
     echo $i config has been dumped sucessfully
done

echo "backup configs"
BACKUP_TIME=$(date +%Y%m%d%H%M%S)
borg create --progress --compression zstd,6 $BORG_URI::vm-configs-${BACKUP_TIME} /tmp/vmconfigs

echo "making list of volumes"
rm -f /tmp/vollist.txt
for i in $(virsh pool-list --name); do
  echo "$(virsh vol-list $i | awk '{print $2}' | grep qcow2)" >> /tmp/vollist.txt
  echo "\n" >> /tmp/vollist.txt
done

echo "creating snapshots"
for i in $(virsh list --name); do
    dev_name=$(virsh domblklist $i | grep qcow2 | awk '{print $1}')
    qcow_name=$(virsh domblklist $i | grep qcow2 | awk '{print $2}')
    qcow_path=$(grep "${qcow_name}" /tmp/vollist.txt | tail -n 1)
    backup_path=$(echo "${qcow_path}" | sed "s/.qcow2/.pangobackup.qcow2/g")
    echo "now creating snapshot for ${i} volume name: ${qcow_name} located at: ${qcow_path}"
    virsh snapshot-create-as --domain ${i} --no-metadata --atomic --quiesce --disk-only --diskspec ${dev_name},snapshot=external,file=${backup_path}
    echo "now backing up ${i}"
    borg create --progress --compression zstd,6 $BORG_URI::${i}-${BACKUP_TIME} ${qcow_path}
    echo "${i} has been backed up successfully"
    echo "now combining snapshot for ${i}"
    virsh blockcommit ${i} ${dev_name} --active --pivot
    echo "snapshot merged for ${i}";
    echo "removing snapshot for $i: $backup_path";
    rm -f $backup_path
    echo "$backup_path has been removed";
done

