#!/bin/sh
echo "sudo ovs-ofctl -OOpenFlow13 dump-ports-desc br-int"
sudo ovs-ofctl -OOpenFlow13 dump-ports-desc br-int

