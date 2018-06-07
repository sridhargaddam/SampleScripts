#!/bin/sh
# Credit Josh

. stackrc admin admin
name=$1
shift

if [ $name == controllers ]
then
        name="controller-0 controller-1 controller-2"
fi
for i in $name
do
        echo ssh\'ing to $i 
        ssh heat-admin@$(nova list 2>/dev/null | grep $i | grep -o "192.168[^ ]*") $@
done

