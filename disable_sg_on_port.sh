#!/bin/sh
if [ $# -ne 1 ]; then
    echo "Usage: $0 <port-id> "
    exit 1
fi

echo "Disabling port security on Neutron Port: $1"
neutron port-update --no-security-groups $1
neutron port-update --port_security_enabled=False $1
neutron port-show $1 | grep port_security_enabled

