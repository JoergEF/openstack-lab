#!/usr/bin/env bash
# Allgemeines Housekeeping für alle Nodes
export DEBIAN_FRONTEND=noninteractive

echo "***** Step 1: Common Provisioning"

echo "***** update packages list and system"
apt-get update
apt-get -y upgrade
apt-get -qy install apt-transport-https aptitude

echo "***** install pip3 to install a recent enough version of ansible"
apt-get -qy install python3-pip
apt-get -qy install python3-dev libffi-dev gcc libssl-dev python3-selinux python3-setuptools
pip3 install ansible==2.9.0

echo "***** declare static host part of the cluster"
echo "192.168.50.68 openstack" >> /etc/hosts
echo "192.168.50.75 deploy" >> /etc/hosts
echo "192.168.50.76 controller01" >> /etc/hosts
echo "192.168.50.77 controller02" >> /etc/hosts
echo "192.168.50.78 compute01" >> /etc/hosts
echo "192.168.50.253 rt-b" >> /etc/hosts

echo "***** prepare ssh key injection (either key (deploy machine) or public one (cluster))"
mkdir -p /root/.ssh
