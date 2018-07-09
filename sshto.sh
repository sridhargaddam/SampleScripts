#!/bin/sh
# Credit Josh

if [ $# -ne 2 ]; then
    echo "Usage: $0 <operation> <command>
       Example: ./sshto.sh compute-1  \"/usr/sbin/ip  a | grep 172.17.2.\""
    exit 1
fi


. ~/stackrc admin admin
name=$1
shift

if [ $name == controllers ]
then
    name="controller-0 controller-1 controller-2"
fi
for i in $name
do
    echo ssh\'ing to $i 
    ssh -o StrictHostKeyChecking=no  heat-admin@$(nova list 2>/dev/null | grep $i | grep -o "192.168[^ ]*") $@
done

