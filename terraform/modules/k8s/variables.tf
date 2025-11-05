variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier where the cluster will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet identifiers available to the control plane."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet identifiers used for worker nodes."
  type        = list(string)
  default     = []
}

variable "node_group" {
  description = "Configuration for the default managed node group."
  type = object({
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    instance_types   = list(string)
    disk_size        = number
  })
}

variable "tags" {
  description = "Tags inherited by cluster resources."
  type        = map(string)
  default     = {}
}
