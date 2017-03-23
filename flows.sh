#!/bin/sh
if [ $# -eq 1 ]; then
    echo "sudo ovs-ofctl -OOpenFlow13 dump-flows br-int | cut -f3- -d','"
    sudo ovs-ofctl -OOpenFlow13 dump-flows br-int | cut -f3- -d',' 
else
    echo "sudo ovs-ofctl -OOpenFlow13 dump-flows br-int"
    sudo ovs-ofctl -OOpenFlow13 dump-flows br-int
fi

