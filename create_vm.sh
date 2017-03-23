#!/bin/bash

if [[ "$NS" == "" ]]; then
    echo "Please define the namespace name in NS environment variable"
    exit 1
fi

if [[ "$MAC" == "" ]]; then
    echo "Please define the Mac address in MAC environment variable"
    exit 1
fi

if [[ "$LPORT" == "" ]]; then
    echo "Please define the lport name in LPORT environment variable"
    exit 1
fi

sudo ip netns add $NS
sudo ovs-vsctl add-port br-int $NS -- set interface $NS type=internal
sudo ip link set $NS netns $NS
sudo ip netns exec $NS ip link set $NS address $MAC
sudo ip netns exec $NS ip link set $NS up
sudo ovs-vsctl set Interface $NS external_ids:iface-id=$LPORT
sudo ip netns exec $NS ip addr show

