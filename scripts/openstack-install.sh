#!/usr/bin/env bash
# provisioniert Openstack vom Deploy-Rechner aus
export DEBIAN_FRONTEND=noninteractive

echo "***** Step 2: Installing Kolla-Ansible and run it"

echo "*****  fixing hostname"
hostname deploy
echo "deploy" > /etc/hostname

echo "*****  installing kolla from pip3 repo"
pip3 install kolla-ansible

echo "*****  getting default configuration for kolla"
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/ 

echo "*****  altering configuration to match our configuration and choices in terms of distribution, network and virtualization engine (QEMU because Virtualbox does not do nested virtualization)"
# a) we are adding centralized logging, which will install a ELK instance listening on http://192.168.50.68:5601
# b) we need to change keepalived virtual router id in order to elimiate conflict with concurrent openstack on the network
sed -i s/'#openstack_release: "ussuri"'/'openstack_release: "rocky"'/g /etc/kolla/globals.yml
sed -i s/'#kolla_internal_vip_address: "10.10.10.254"'/'kolla_internal_vip_address: "192.168.50.68"'/g /etc/kolla/globals.yml
sed -i s/'#network_interface: "eth0"'/'network_interface: "enp0s8"'/g /etc/kolla/globals.yml
#sed -i s/'#enable_haproxy: "yes"'/'enable_haproxy: "yes"'/g /etc/kolla/globals.yml
sed -i s/'#neutron_external_interface: "eth1"'/'neutron_external_interface: "enp0s9"'/g /etc/kolla/globals.yml
sed -i s/'#nova_compute_virt_type: "kvm"'/'nova_compute_virt_type: "qemu"'/g /etc/kolla/globals.yml
sed -i s/'#enable_central_logging: "no"'/'enable_central_logging: "yes"'/g /etc/kolla/globals.yml
sed -i s/'#keepalived_virtual_router_id: "51"'/'keepalived_virtual_router_id: "251"'/g /etc/kolla/globals.yml

echo "*****  Generating password and keeping a copy in this directory"
kolla-genpwd 
cp /etc/kolla/passwords.yml /vagrant/

echo "*****  deploy SSH key generated previously (Vagrantfile)"
cat /vagrant/ssh_key > /root/.ssh/id_rsa 
cat /vagrant/ssh_key.pub > /root/.ssh/id_rsa.pub
chmod go-rwx /root/.ssh/id_rsa

echo "*****  fingerprinting ssh across all the hosts of the cluster"
ssh-keyscan controller01 >> /root/.ssh/known_hosts
ssh-keyscan controller02 >> /root/.ssh/known_hosts
ssh-keyscan compute01 >> /root/.ssh/known_hosts

echo "*****  Running Kolla"
echo "***** Bootstrap-Servers"
kolla-ansible -i /vagrant/conf/3-nodes bootstrap-servers
echo "***** Prechecks"
#kolla-ansible -i /vagrant/conf/3-nodes prechecks
echo "***** Deploy"
#kolla-ansible -i /vagrant/conf/3-nodes deploy
echo "***** Post-Depoly"
#kolla-ansible -i /vagrant/conf/3-nodes post-deploy
