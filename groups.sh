#!/bin/sh
echo "sudo ovs-ofctl -OOpenFlow13 dump-groups br-int "
sudo ovs-ofctl -OOpenFlow13 dump-groups br-int 
