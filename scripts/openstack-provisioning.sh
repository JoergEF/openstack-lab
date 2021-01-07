#!/usr/bin/env bash
# konfiguriert die Mitglieder des Clusters
DEBIAN_FRONTEND=noninteractive

# copy configuration-file for neutron-nic and apply
cp /vagrant/conf/60-enp0s9.yaml /etc/netplan
netplan apply

# deploy public ssh key so that the deploy node can run ansible
cat /vagrant/ssh_key.pub >> /root/.ssh/authorized_keys
