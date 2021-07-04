terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu-qcow2" {
  name = "ubuntu-sensor2.qcow2"
  pool = "default"
  source = "http://cloud-images.ubuntu.com/releases/focal/release-20210429/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = "${data.template_file.user_data.rendered}"
}

# Define KVM domain to create
resource "libvirt_domain" "sensor2" {
  name   = "sensor2"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

}

# Output Server IP
output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.sensor2.*.network_interface.0.addresses
}