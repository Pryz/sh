#!/usr/bin/env bash

LISTVMS='list_vms.txt'
VMDEF='generic.xml'
TMPDEF='/tmp/vm.xml'
SED='sed -i'
DISKPATH='/var/lib/libvirt/images'
DISKSIZE='8G'
LOGFILE='/tmp/vm.log'

if [ ! -f "$LISTVMS" -o ! -f "$VMDEF" ]
then
    echo "Error : $LISTVMS or $VMDEF not found"
    exit
fi

[ -f $LOGFILE ] && $(> $LOGFILE)
cp $VMDEF $TMPDEF

for vmname in $(cat $LISTVMS); do 
    # Skip commented names
    [[ $vmname == \#* ]] && echo "Skip $vmname" && continue
    echo "Build $vmname"

    # If needed, remove old instance
    $(virsh list --all|grep $vmname &> /dev/null)
    if [ $? -eq 0 ]; then
        echo "Remove old $vmname and its storage"
        $(virsh undefine $vmname --remove-all-storage &>> $LOGFILE)
    fi

    # Delete old disk if exists and create new one
    DISK="$DISKPATH/$vmname.img"
    [ -f $DISK ] && $(sudo rm -f $DISK)
    $(sudo qemu-img create -f raw $DISKPATH/$vmname.img $DISKSIZE &>> $LOGFILE)

    # Edit definition file
    $SED "/<name>/ s/\>.*\</\>$vmname\<\//" $TMPDEF;
    $SED "/uuid/ s/\>.*\</\>$(uuidgen)\<\//" $TMPDEF;
    $SED "/libvirt\/images/ s/\w*\.img/$vmname\.img/" $TMPDEF;

    # Create the virtual machine
    echo "Define $vmname"
    $(virsh define $TMPDEF &>> $LOGFILE)
done

echo "Log : $LOGFILE"

# Mr Proper
rm -f $TMPDEF
