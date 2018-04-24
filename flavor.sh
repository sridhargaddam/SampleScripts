#!/bin/sh
echo "Creating a minimal flavor for Cirros image"
echo "flavor-create --is-public true m1.extra_tiny1 auto 100 0 1 --rxtx-factor 1"
nova flavor-create --is-public true m1.extra_tiny auto 100 0 1 --rxtx-factor 1
