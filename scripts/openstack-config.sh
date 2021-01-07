#!/usr/bin/env bash
# konfiguriert die Mitglieder des Clusters nach dem Provisioning mittels Ansible
export DEBIAN_FRONTEND=noninteractive

# fix locales (in order to make openstack client happy)
echo 'LC_ALL="en_US.UTF-8"'  >>  /etc/default/locale
echo 'LC_CTYPE="en_US.UTF-8"'  >>  /etc/default/locale

# install openstack client and load variables with admin credentials
pip3 install python3-openstackclient
source /etc/kolla/admin-openrc.sh

# create public network
openstack network create --external --provider-physical-network physnet1 --provider-network-type flat public1
openstack subnet create --no-dhcp --allocation-pool start=192.168.50.150,end=192.168.50.170 --network public1 --subnet-range 192.168.50.0/24 --gateway 192.168.50.253 public1-subnet

# adding flavor
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge

# create labsuser/labpassword user with admin level
openstack project create --description 'Openstack Lab' lab --domain default
openstack user create --project lab --password labpassword labuser
openstack role add --user labuser --project lab admin