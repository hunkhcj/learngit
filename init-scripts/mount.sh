#!/bin/bash

echo "Info: Start checking automount disk..." >> /var/log/cloudinit.log
ftype=$1
sleep 120
datadir="/data"
i=0
devdirs=$(lsblk -n -d -p| awk '{print $1}'|xargs)
curtime=`date '+%H%M%S'`

for devdir in $devdirs ; do
    fstype=$(file -s $devdir | awk '{print $2}')
    if [ "$fstype" = "data" ]; then
        echo "Info: Creating file system on $devdir ..." >> /var/log/cloudinit.log
        if [ "$i" -eq 0 ]; then
            mountdir=$datadir
            i=$(($i+1))
        else
            mountdir=$datadir$i
            i=$(($i+1))
        fi
        mkfs -q -t $ftype $devdir
        mkdir $mountdir
        chmod 777 $mountdir
        mount $devdir $mountdir
        cp -a /etc/fstab /etc/fstab.org.$i.$curtime
        devuuid=$(blkid $devdir| awk '{print $2}')
        echo "$devuuid $mountdir $ftype defaults  0 0" >> /etc/fstab
    else
        echo "Info: $devdir already mounted, so exit ..."  >> /var/log/cloudinit.log
    fi
done
