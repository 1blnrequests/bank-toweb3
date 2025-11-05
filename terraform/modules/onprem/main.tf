locals {
  node_indices = range(var.vm_count)
}

data "vsphere_datacenter" "this" {
  name = var.datacenter
}

data "vsphere_datastore" "this" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "this" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_folder" "this" {
  path          = var.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_virtual_machine" "nodes" {
  count = var.vm_count

  name             = format("%s-%02d", var.hostname_prefix, count.index + 1)
  resource_pool_id = data.vsphere_resource_pool.this.id
  datastore_id     = data.vsphere_datastore.this.id
  folder           = vsphere_folder.this.path

  num_cpus = var.cpu
  memory   = var.memory_mb

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = try(data.vsphere_virtual_machine.template.network_interface_types[0], "vmxnet3")
  }

  disk {
    label            = "disk0"
    size             = var.disk_gb
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.hostname_prefix, count.index + 1)
        domain    = var.domain
      }

      network_interface {
        ipv4_address = element(var.ip_addresses, count.index)
        ipv4_netmask = var.ipv4_prefix_length
      }

      ipv4_gateway    = var.gateway
      dns_server_list = var.dns_servers
    }
  }

  custom_attributes = merge(var.tags, {
    "platform" = "web3-hybrid"
  })
}
