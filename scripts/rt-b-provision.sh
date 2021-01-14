#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# Konfiguration der Namensauflösung
systemctl disable --now systemd-resolved
rm /etc/resolv.conf
echo "nameserver 10.50.100.11" >> /etc/resolv.conf
echo "search training.erfurt.iad.de" >> /etc/resolv.conf
apt-get -y install dnsmasq

# Konfiguration von Firewall und NAT
apt-get -y install firehol
cp /vagrant/conf/etc-firehol.conf /etc/firehol/firehol.conf
cp /vagrant/conf/etc-default-firehol /etc/default/firehol
firehol start
