#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <operation> <use-case> 
    operation: s: for setup, d: for deletion 
    use-case: (IPv4: 1-19, IPv6: 20-30, DualStack: 40-50
    1  (IPv4): Single IPv4 Network connected to a Neutron Router 
    10 (IPv4-External): Single IPv4 Network connected to a Neutron Router with external connectivity
    11 (IPv4-EastWest): Two IPv4 Networks connected to a Neutron Router for validating east-west routing support
    20 (IPv6): Single IPv6 Network connected to a Neutron Router 
    21 (IPv6-EastWest): Two IPv6 Networks connected to a Neutron Router for validating east-west routing support
    40 (DualStack): Network with V4/V6 subnets connected to a Neutron Router
    41 (DualStack-EastWest): Two IPv6 & IPv4 Networks connected to a Neutron Router for validating east-west routing support"
    exit 1
fi

# CONSTANTS
EXT_NET_ONE="ext-net"
NET_ONE="n1"
NET_TWO="n2"
IPV4_EXT_SUBNET_ONE="ipv4_ext_s1"
IPV4_SUBNET_ONE="ipv4_s1"
IPV4_SUBNET_TWO="ipv4_s2"
IPV4_EXT_CIDR_ONE="192.168.124.0/24"
IPV4_CIDR_ONE="10.0.0.0/24"
IPV4_CIDR_TWO="20.0.0.0/24"
IPV6_SUBNET_ONE="ipv6_s1"
IPV6_SUBNET_TWO="ipv6_s2"
IPV6_CIDR_ONE="2001:db8:1111::/64"
IPV6_CIDR_TWO="2001:db8:2222::/64"
ROUTER_ONE="r1"


function create_network() {
    echo "Creating a network with name $1"
    neutron net-create $1 
}

function create_ext_flat_network() {
    echo "Creating an external flat network with name $1"
    neutron net-create --router:external=True --provider:network_type flat --provider:physical_network public $1
}

function delete_network() {
    echo "Deleting the network with name $1"
    neutron net-delete $1 
}

function create_v4_subnet() {
    # $1 : SubnetName
    # $2 : Network Name
    # $3 : CIDR 
    echo "Creating an IPv4 Subnet with name $1, network $2, CIDR $3"
    neutron subnet-create --name $1 --ip-version 4 $2 $3
}


function create_v4_ext_subnet() {
    # $1 : SubnetName
    # $2 : Network Name
    # $3 : CIDR 
    echo "Creating an IPv4 Subnet with name $1, network $2, CIDR $3"
    neutron subnet-create --name $1 --ip-version 4 --allocation-pool start=192.168.124.110,end=192.168.124.120 --gateway=192.168.124.1 --disable-dhcp $2 $3
}

function create_v6_subnet() {
    # $1 : SubnetName
    # $2 : Network Name
    # $3 : CIDR 
    echo "Creating an IPv6 Subnet with name $1, network $2, CIDR $3"
    neutron subnet-create --name $1 --ip-version 6 --ipv6-ra-mode slaac --ipv6-address-mode slaac $2 $3
}


function delete_subnet() {
    echo "Deleting the Subnet with name $1"
    neutron subnet-delete $1 
}

function create_router() {
    echo "Creating a Router with name $1"
    neutron router-create $1
}

function delete_router() {
    echo "Deleting Router with name $1"
    neutron router-delete $1 
}

function associate_router() {
    # $1: RouterID
    # $2: SubnetID
    echo "Associating Router $1 with Subnet $2"
    neutron router-interface-add $1 $2
}

function router_gateway_set() {
    # $1: RouterID
    # $2: NetworkID
    echo "Associating Router $1 with External Network $2"
    neutron router-gateway-set $1 $2
}

function router_gateway_clear() {
    # $1: RouterID
    # $2: NetworkID
    echo "Disassociating Router $1 from External Network $2"
    neutron router-gateway-clear $1 $2
}

function dissociate_router() {
    # $1: RouterID
    # $2: SubnetID
    echo "Dissociating Router $1 from Subnet $2"
    neutron router-interface-delete $1 $2
}

if [ $2 == 1 ]; then
    # (IPv4): Single IPv4 Network connected to a Neutron Router
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v4_subnet $IPV4_SUBNET_ONE $NET_ONE $IPV4_CIDR_ONE
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_ONE
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        delete_router $ROUTER_ONE
        delete_subnet $IPV4_SUBNET_ONE
        delete_network $NET_ONE
    fi     
elif [ $2 == 10 ]; then
    # (IPv4): Single IPv4 Network connected to a Neutron Router with external connectivity
    if [ $1 == 's' ]; then
        create_ext_flat_network $EXT_NET_ONE
        create_v4_ext_subnet $IPV4_EXT_SUBNET_ONE $EXT_NET_ONE $IPV4_EXT_CIDR_ONE
        create_network $NET_ONE
        create_v4_subnet $IPV4_SUBNET_ONE $NET_ONE $IPV4_CIDR_ONE
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        router_gateway_set $ROUTER_ONE $EXT_NET_ONE
    elif [ $1 == 'd' ]; then
        router_gateway_clear $ROUTER_ONE $EXT_NET_ONE
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        delete_router $ROUTER_ONE
        delete_subnet $IPV4_SUBNET_ONE
        delete_subnet $IPV4_EXT_SUBNET_ONE
        delete_network $NET_ONE
        delete_network $EXT_NET_ONE
    fi  
elif [ $2 == 11 ]; then
    # (IPv4-EastWest): IPv4 East-West Routing support
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v4_subnet $IPV4_SUBNET_ONE $NET_ONE $IPV4_CIDR_ONE
        create_network $NET_TWO
        create_v4_subnet $IPV4_SUBNET_TWO $NET_TWO $IPV4_CIDR_TWO
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_TWO
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_TWO
        delete_router $ROUTER_ONE
        delete_subnet $IPV4_SUBNET_ONE
        delete_subnet $IPV4_SUBNET_TWO
        delete_network $NET_ONE
        delete_network $NET_TWO
    fi     
elif [ $2 == '20' ]; then
    # (IPv6): Single IPv6 Network connected to a Neutron Router
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v6_subnet $IPV6_SUBNET_ONE $NET_ONE $IPV6_CIDR_ONE
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV6_SUBNET_ONE
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        delete_router $ROUTER_ONE
        delete_subnet $IPV6_SUBNET_ONE
        delete_network $NET_ONE
    fi     
elif [ $2 == '21' ]; then
    # (IPv6-EastWest): Two IPv6 Networks connected to a Neutron Router for validating east-west routing support
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v6_subnet $IPV6_SUBNET_ONE $NET_ONE $IPV6_CIDR_ONE
        create_network $NET_TWO
        create_v6_subnet $IPV6_SUBNET_TWO $NET_TWO $IPV6_CIDR_TWO
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        associate_router $ROUTER_ONE $IPV6_SUBNET_TWO
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_TWO
        delete_router $ROUTER_ONE
        delete_subnet $IPV6_SUBNET_ONE
        delete_subnet $IPV6_SUBNET_TWO
        delete_network $NET_ONE
        delete_network $NET_TWO
    fi     
elif [ $2 == '40' ]; then
    # (DualStack): Network with V4/V6 subnets connected to a Neutron Router
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v4_subnet $IPV4_SUBNET_ONE $NET_ONE $IPV4_CIDR_ONE
        create_v6_subnet $IPV6_SUBNET_ONE $NET_ONE $IPV6_CIDR_ONE
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        associate_router $ROUTER_ONE $IPV6_SUBNET_ONE
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        delete_router $ROUTER_ONE
        delete_subnet $IPV4_SUBNET_ONE
        delete_subnet $IPV6_SUBNET_ONE
        delete_network $NET_ONE
    fi     
elif [ $2 == '41' ]; then
    # (DualStack-EastWest): Two IPv6 & IPv4 Networks connected to a Neutron Router for validating east-west routing support
    if [ $1 == 's' ]; then
        create_network $NET_ONE
        create_v4_subnet $IPV4_SUBNET_ONE $NET_ONE $IPV4_CIDR_ONE
        create_v6_subnet $IPV6_SUBNET_ONE $NET_ONE $IPV6_CIDR_ONE
        create_network $NET_TWO
        create_v4_subnet $IPV4_SUBNET_TWO $NET_TWO $IPV4_CIDR_TWO
        create_v6_subnet $IPV6_SUBNET_TWO $NET_TWO $IPV6_CIDR_TWO
        create_router $ROUTER_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        associate_router $ROUTER_ONE $IPV4_SUBNET_TWO
        associate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        associate_router $ROUTER_ONE $IPV6_SUBNET_TWO
    elif [ $1 == 'd' ]; then
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_ONE
        dissociate_router $ROUTER_ONE $IPV4_SUBNET_TWO
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_ONE
        dissociate_router $ROUTER_ONE $IPV6_SUBNET_TWO
        delete_router $ROUTER_ONE
        delete_subnet $IPV4_SUBNET_ONE
        delete_subnet $IPV4_SUBNET_TWO
        delete_subnet $IPV6_SUBNET_ONE
        delete_subnet $IPV6_SUBNET_TWO
        delete_network $NET_ONE
        delete_network $NET_TWO
    fi    
fi
