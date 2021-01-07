# provision lab openstack using lab login/password
provider "openstack" {
 user_name = "labuser"
 tenant_name = "lab"
 password = "labpassword"
 auth_url = "http://192.168.50.68:5000/v3"
 domain_id = "default"
}

# provision SSH key for yan's laptop
resource "openstack_compute_keypair_v2" "laptop" {
  name = "laptop"
  public_key = "" # customize the SSH key here
}

# push a ubuntu image
resource "openstack_images_image_v2" "ubuntu-xenial" {
  name   = "ubuntu16.04"
  image_source_url = "http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
  container_format = "bare"
  disk_format = "qcow2"
  visibility = "public"
}

# security group
resource "openstack_networking_secgroup_v2" "test-network-secgroup" {
  name        = "test-network-secgroup"
  description = "test Network security group"
}

resource "openstack_networking_secgroup_rule_v2" "testnet-secgroup-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "testnet-secgroup-icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

# create a dedicated network
resource "openstack_networking_network_v2" "test-network" {
  name = "test-network"
  admin_state_up = "true"
}

# add a subnetwork associated to the network
resource "openstack_networking_subnet_v2" "test-network-subnet" {
  name = "test-network-subnet"
  network_id = "${openstack_networking_network_v2.test-network.id}"
  cidr = "192.168.188.0/24"
  ip_version = 4
  dns_nameservers = ["192.168.50.253"]
}

# add a router specific for our new ISP
resource "openstack_networking_router_v2" "test-network-router" {
  region = ""
  name = "test-network-router"
  admin_state_up = "true"
  external_network_id = ""  # customize the external network here
}

# associate router
resource "openstack_networking_router_interface_v2" "test-network-intf" {
  region = ""
  router_id = "${openstack_networking_router_v2.test-network-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.test-network-subnet.id}"
}

# create a floating IP
resource "openstack_compute_floatingip_v2" "test-network-fip" {
  region = ""
  pool = "public1"
}


resource "openstack_compute_floatingip_associate_v2" "test_network-fip-associate" {
  floating_ip = "${openstack_compute_floatingip_v2.test-network-fip.address}"
  instance_id = "${openstack_compute_instance_v2.test-network.id}"
  wait_until_associated = true

  # we install ansible support in the target VM
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "${openstack_compute_floatingip_v2.test-network-fip.address}"
      user     = "ubuntu"
      private_key = "${file("/Users/USERNAME/.ssh/id_rsa")}" # your username likely here
    }

    inline = [
    "sudo apt-get -qy update"
    ]
  }

}

# instanciate our ubuntu 16.04
resource "openstack_compute_instance_v2" "test-network" {
  depends_on = ["openstack_networking_subnet_v2.test-network-subnet","openstack_images_image_v2.ubuntu-xenial"]
  region = ""
  name = "test_ubuntu_xenial"
  image_name = "ubuntu16.04"
  flavor_name = "m1.small" # minimal size for this Ubuntu image (>2GB)
  key_pair = "laptop"
  security_groups = ["test-network-secgroup"]

  network = {
    name = "${openstack_networking_network_v2.test-network.name}"
  }

}
