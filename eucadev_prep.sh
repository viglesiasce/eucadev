#!/bin/bash
echo "timeout=300" >> /etc/yum.conf
yum install -y ebtables git
git config --global http.postBuffer 524288000
echo "* soft nproc 64000" >>/etc/security/limits.conf
echo "* hard nproc 64000" >>/etc/security/limits.conf
rm /etc/security/limits.d/90-nproc.conf # these apparently override limits.conf?
echo "DEVICE=br0
TYPE=Bridge
ONBOOT=yes
DELAY=0
BOOTPROTO=static
IPADDR=192.168.192.101
NETMASK=255.255.255.0" >>/etc/sysconfig/network-scripts/ifcfg-br0
service network restart
ebtables -I FORWARD -o eth1 -j DROP
ebtables -I OUTPUT -o eth1 -j DROP
/etc/init.d/ebtables save
chkconfig --level 345 ebtables on
