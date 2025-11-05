variable "datacenter" {
  description = "Name of the vSphere datacenter hosting the private cloud workloads."
  type        = string
}

variable "datastore" {
  description = "Name of the datastore backing the on-premises virtual machines."
  type        = string
}

variable "resource_pool" {
  description = "Resource pool that provides compute capacity for the in-house cluster."
  type        = string
}

variable "network" {
  description = "Network or port-group used to attach the provisioned nodes."
  type        = string
}

variable "template" {
  description = "Name of the virtual machine template that will be cloned."
  type        = string
}

variable "folder" {
  description = "vSphere folder that stores the provisioned virtual machines."
  type        = string
}

variable "hostname_prefix" {
  description = "Prefix applied to the hostname of each provisioned node."
  type        = string
}

variable "domain" {
  description = "Domain suffix appended to each generated hostname."
  type        = string
}

variable "vm_count" {
  description = "Number of virtual machines to provision."
  type        = number
}

variable "cpu" {
  description = "Number of virtual CPUs assigned to each node."
  type        = number
}

variable "memory_mb" {
  description = "Memory in MiB assigned to each node."
  type        = number
}

variable "disk_gb" {
  description = "Size of the primary disk in GiB."
  type        = number
}

variable "gateway" {
  description = "Default IPv4 gateway configured for each node."
  type        = string
}

variable "dns_servers" {
  description = "List of DNS servers configured on each node."
  type        = list(string)
  default     = []
}

variable "ip_addresses" {
  description = "List of static IPv4 addresses assigned to the nodes."
  type        = list(string)
}

variable "ipv4_prefix_length" {
  description = "Prefix length (CIDR) applied to the IPv4 network interface."
  type        = number
}

variable "tags" {
  description = "Map of tags replicated as vSphere custom attributes."
  type        = map(string)
  default     = {}
}
