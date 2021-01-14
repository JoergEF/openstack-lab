# -*- mode: ruby -*-

# generate SSH key in the folder if they don't exist already
system('[ -f ssh_key ] || ssh-keygen -f ssh_key -P ""')
system('[ $(vagrant plugin list | grep -c vagrant-disksize) = "0" ] && vagrant plugin install vagrant-disksize')

Vagrant.configure("2") do |config|

  $physical_interface = "enp10s1"

  $common_provisioning = "scripts/common-provisioning.sh"

  # this section is responsible for configuring the VM nodes part of the cluster
  $openstack_provisioning = "scripts/openstack-provisioning.sh"

  # set the default route on hosts after reboot
  $change_defaultroute = "scripts/change-defaultroute.sh"

  # this section is responsible for configuring Openstack after the ansible scripts are run
  $openstack_config = "scripts/openstack-config.sh"

  # this section is reponsible for installing Kolla on the deploy host and then trigger the deployment
  $openstack_install = "scripts/openstack-install.sh"

  # the router
  config.vm.define "rt-b" do |rtb|
    rtb.vm.box = "ubuntu/focal64"
    rtb.vm.hostname = "rt-b"
    rtb.vm.network "public_network", bridge: $physical_interface, ip: "192.168.50.253"
    rtb.vm.provider "virtualbox" do |vb|
      vb.name = "rt-b"
      vb.cpus = "1"
      vb.memory = "2048"
    end
    
    # housekeeping
    rtb.vm.provision "shell", path: $common_provisioning

    # provisioning
    rtb.vm.provision "shell", path: "scripts/rtb-provision.sh"


    # rebooting
    rtb.trigger.after [:provision] do |t|
      t.name = "Reboot after provisioning"
      t.run = { :inline => "vagrant reload" }
    end
  end
  
  # a controler 
  config.vm.define "controller01" do |controller01|
    controller01.vm.box = "ubuntu/bionic64"

    controller01.vm.provider "virtualbox" do |v|
      v.name = "kolla-multinode-controller01"
      v.memory = 8192 
      v.cpus = 2
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end

    controller01.vm.network "public_network", bridge: $physical_interface, ip: "192.168.50.76" 
    controller01.vm.network "public_network", bridge: $physical_interface, auto_config: false

    # housekeeping
    controller01.vm.provision "shell", path: $common_provisioning

    # prepare for hosting openstack (mainly network interface + ssh)
    controller01.vm.provision "shell", path: $openstack_provisioning
    controller01.vm.provision "shell", path: $change_defaultroute, run: "always"

    # fix hostname (as RabbitMQ is using only hostname, this is necessary for the messaging between nodes to work)
    controller01.vm.provision "shell", inline: <<-SHELL
    hostname controller01
    echo "controller01" > /etc/hostname
    SHELL

    # rebooting
    controller01.trigger.after [:provision] do |t|
      t.name = "Reboot after provisioning"
      t.run = { :inline => "vagrant reload" }
    end

  end

  # a second controler
  config.vm.define "controller02" do |controller02|
    controller02.vm.box = "ubuntu/bionic64"

    controller02.vm.provider "virtualbox" do |v|
      v.name = "kolla-multinode-controller02"
      v.memory = 8192 
      v.cpus = 2
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end

    controller02.vm.network "public_network", bridge: $physical_interface, ip: "192.168.50.77" 
    controller02.vm.network "public_network", bridge: $physical_interface, auto_config: false

    # housekeeping
    controller02.vm.provision "shell", path: $common_provisioning

    # prepare for hosting openstack (mainly network interface + ssh)
    controller02.vm.provision "shell", path: $openstack_provisioning
    controller02.vm.provision "shell", path: $change_defaultroute, run: "always"

    # fix hostname (as RabbitMQ is using only hostname, this is necessary for the messaging between nodes to work)
    controller02.vm.provision "shell", inline: <<-SHELL
    hostname controller02
    echo "controller02" > /etc/hostname
    SHELL

    # rebooting
    controller02.trigger.after [:provision] do |t|
      t.name = "Reboot after provisioning"
      t.run = { :inline => "vagrant reload" }
    end


  end

  # a compute resource
  config.vm.define "compute01" do |compute01|
    compute01.vm.box = "ubuntu/bionic64"
    compute01.disksize.size = '120GB' # require vagrant plugin disk-resize

    compute01.vm.provider "virtualbox" do |v|
      v.name = "kolla-multinode-compute01"
      v.memory = 8192 
      v.cpus = 4
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end

    compute01.vm.network "public_network", bridge: $physical_interface, ip: "192.168.50.78" 
    compute01.vm.network "public_network", bridge: $physical_interface, auto_config: false

    # housekeeping
    compute01.vm.provision "shell", path: $common_provisioning

    # prepare for hosting openstack (mainly network interface + ssh)
    compute01.vm.provision "shell", path: $openstack_provisioning
    compute01.vm.provision "shell", path: $change_defaultroute, run: "always"

    # fix hostname (as RabbitMQ is using only hostname, this is necessary for the messaging between nodes to work)
    compute01.vm.provision "shell", inline: <<-SHELL
    hostname compute01
    echo "compute01" > /etc/hostname
    SHELL

    # rebooting
    compute01.trigger.after [:provision] do |t|
      t.name = "Reboot after provisioning"
      t.run = { :inline => "vagrant reload" }
    end

  end

  # a provisioner machine that will execute Kolla and pilot the deployment of Openstack
  config.vm.define "deploy" do |deploy|
    deploy.vm.box = "ubuntu/bionic64"

    deploy.vm.provider "virtualbox" do |v|
      v.name = "kolla-multinode-deploy"
      v.memory = 2048 
      v.cpus = 1
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"] 
    end

    deploy.vm.network "public_network", bridge: $physical_interface, ip: "192.168.50.75" 

    # housekeeping
    deploy.vm.provision "shell", path: $common_provisioning
    
    # install kolla and deploy openstack using ansible scripts provided by Kolla
    deploy.vm.provision "shell", path: $openstack_install

    # configure newly install openstack with a labuser account
    #deploy.vm.provision "shell", path: $openstack_config

  end

end
