variable "cluster_name" {
  description = "Name of the MSK cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier hosting the MSK cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where Kafka brokers will be deployed."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to reach the brokers."
  type        = list(string)
}

variable "broker_instance_type" {
  description = "Instance type for broker nodes."
  type        = string
}

variable "number_of_broker_nodes" {
  description = "Total number of broker nodes."
  type        = number
}

variable "ebs_volume_size" {
  description = "Size of each broker EBS volume in GiB."
  type        = number
}

variable "enhanced_monitoring_level" {
  description = "Enhanced monitoring level to apply."
  type        = string
}

variable "tags" {
  description = "Tags inherited by MSK resources."
  type        = map(string)
  default     = {}
}
