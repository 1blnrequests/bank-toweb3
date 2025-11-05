output "hostnames" {
  description = "Hostnames of the provisioned on-premises nodes."
  value       = [for vm in vsphere_virtual_machine.nodes : vm.name]
}

output "ip_addresses" {
  description = "Static IPv4 addresses assigned to the in-house nodes."
  value       = [for idx in range(length(vsphere_virtual_machine.nodes)) : element(var.ip_addresses, idx)]
}

output "folder" {
  description = "Folder that groups the in-house workload VMs."
  value       = vsphere_folder.this.path
}
