#!/usr/bin/env bash
# konfiguriert die Mitglieder des Clusters
export DEBIAN_FRONTEND=noninteractive

echo "***** Step 2: Openstack Provisioning"

echo "*****  copy configuration-file for neutron-nic and apply"
cp /vagrant/conf/60-enp0s9.yaml /etc/netplan
netplan apply

echo "*****  deploy public ssh key so that the deploy node can run ansible"
cat /vagrant/ssh_key.pub >> /root/.ssh/authorized_keys
