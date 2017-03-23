#!/bin/sh
echo "sudo ovs-ofctl -OOpenFlow13 dump-group-stats br-int "
sudo ovs-ofctl -OOpenFlow13 dump-group-stats br-int 
