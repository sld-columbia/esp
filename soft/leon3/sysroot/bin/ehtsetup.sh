#!/bin/sh

export IP=`ifup eth0 | grep Lease | awk '{print $3}'`
export PASSWORD=ciao123
ifconfig eth0 $IP
echo root:$PASSWORD | chpasswd

echo "IP = $IP"
echo "root password = $PASSWORD"
