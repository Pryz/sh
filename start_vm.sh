#!/usr/bin/env bash

LOGFILE="/tmp/vm.log"
VMNAME=$1

startvm () {
    [ -z $1 ] && return
    echo "Start $1"
    
    # Eject cd and floppy
    $(virsh change-media $1 --eject hdc &> $LOGFILE)
    $(virsh change-media $1 --eject fda &> $LOGFILE)
    
    # Start the VM
    $(virsh start $1 &> $LOGFILE)
}

stopvm () {
    [ -z $1 ] && return
    echo "Stop $1"
    $(virsh destroy $1 &> $LOGFILE)
}

if [ -z $1 ]; then
    echo "Usage : $0 <vmname> <action, default:start>"
    exit 1
fi

case $2 in
    "start" | "startvm" )
        startvm $VMNAME
        ;;
    "stop" | "stopvm" )
        stopvm $VMNAME
        ;;
    * )
        echo "No action given"
        startvm $VMNAME
        ;;
    esac

exit
