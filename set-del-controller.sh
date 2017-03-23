#!/bin/sh

if [ $# -lt 1 ]
then
    echo "Usage: $0 <command>"
    echo "1: Create br-int/br-ex and sets the manager/controller for the ovs switch"
    echo "0: Delete the controller/manager from the switch"
    exit
fi

if [ $1 == 1 ]
then
    sudo ovs-vsctl add-br br-int
    sudo ovs-vsctl add-br br-ex
    sudo ovs-vsctl set-manager tcp:192.168.121.1:6640
    sudo ovs-vsctl set-controller br-int tcp:192.168.121.1:6633
    sudo ovs-vsctl show
else
    sudo ovs-vsctl del-controller br-int
    sudo ovs-vsctl del-manager
    sudo ovs-vsctl show
fi

