variable "environment" {
  description = "Environment name used for tagging and naming resources."
  type        = string
  default     = "sandbox"
}

variable "aws_region" {
  description = "AWS region where the infrastructure will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags to apply to created resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnets" {
  description = "Subnet definitions used for the platform network layout."
  type = list(object({
    name   = string
    cidr   = string
    az     = string
    public = bool
  }))
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "web3-platform"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.29"
}

variable "eks_node_group" {
  description = "Configuration for the default EKS managed node group."
  type = object({
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    instance_types   = list(string)
    disk_size        = number
  })
  default = {
    desired_capacity = 2
    max_capacity     = 4
    min_capacity     = 2
    instance_types   = ["m6i.large"]
    disk_size        = 50
  }
}

variable "kafka_cluster_name" {
  description = "Name of the MSK Kafka cluster."
  type        = string
  default     = "web3-kafka"
}

variable "kafka_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to reach the Kafka brokers."
  type        = list(string)
  default     = []
}

variable "kafka_broker_instance_type" {
  description = "Instance type used for Kafka broker nodes."
  type        = string
  default     = "kafka.m5.large"
}

variable "kafka_number_of_broker_nodes" {
  description = "Number of Kafka broker nodes. Must be at least three for production deployments."
  type        = number
  default     = 3
}

variable "kafka_ebs_volume_size" {
  description = "EBS volume size in GiB attached to each Kafka broker node."
  type        = number
  default     = 1000
}

variable "kafka_enhanced_monitoring" {
  description = "Enhanced monitoring level for the MSK cluster."
  type        = string
  default     = "DEFAULT"
}

variable "vault_version" {
  description = "Version of the HashiCorp Vault Helm chart."
  type        = string
  default     = "0.27.0"
}

variable "vault_namespace" {
  description = "Namespace where Vault should be deployed."
  type        = string
  default     = "vault"
}

variable "web3_namespace" {
  description = "Namespace where web3 application workloads will run."
  type        = string
  default     = "web3"
}

variable "enable_observability_stack" {
  description = "Whether to install the kube-prometheus-stack for platform observability."
  type        = bool
  default     = true
}

variable "prometheus_chart_version" {
  description = "Helm chart version for kube-prometheus-stack."
  type        = string
  default     = "55.5.0"
}

variable "prometheus_values" {
  description = "Additional Helm values to merge into the kube-prometheus-stack release."
  type        = any
  default     = {}
}

variable "enable_onprem_workloads" {
  description = "Whether to provision infrastructure backing in-house workloads."
  type        = bool
  default     = false
}

variable "vsphere_server" {
  description = "vSphere API endpoint for managing on-premises workloads."
  type        = string
  default     = ""
}

variable "vsphere_user" {
  description = "vSphere user with permissions to create and manage virtual machines."
  type        = string
  default     = ""
}

variable "vsphere_password" {
  description = "Password for the vSphere user."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vsphere_allow_unverified_ssl" {
  description = "Whether to allow self-signed TLS certificates when connecting to vSphere."
  type        = bool
  default     = false
}

variable "vsphere_datacenter" {
  description = "Name of the target datacenter in vSphere."
  type        = string
  default     = ""
}

variable "vsphere_datastore" {
  description = "Name of the datastore that will host virtual machine disks."
  type        = string
  default     = ""
}

variable "vsphere_resource_pool" {
  description = "Resource pool that provides compute capacity for in-house servers."
  type        = string
  default     = ""
}

variable "vsphere_network" {
  description = "Port group or network label to attach provisioned servers to."
  type        = string
  default     = ""
}

variable "onprem_vm_template" {
  description = "Name of the vSphere virtual machine template used to clone in-house servers."
  type        = string
  default     = ""
}

variable "onprem_vm_folder" {
  description = "Target folder for in-house virtual machines."
  type        = string
  default     = "web3-onprem"
}

variable "onprem_vm_hostname_prefix" {
  description = "Hostname prefix assigned to provisioned in-house servers."
  type        = string
  default     = "web3-edge"
}

variable "onprem_vm_domain" {
  description = "Domain suffix appended to in-house server hostnames."
  type        = string
  default     = "corp.local"
}

variable "onprem_vm_count" {
  description = "Number of in-house servers to provision."
  type        = number
  default     = 3
}

variable "onprem_vm_cpu" {
  description = "Number of virtual CPUs allocated to each in-house server."
  type        = number
  default     = 8
}

variable "onprem_vm_memory_mb" {
  description = "Memory allocated to each in-house server in MiB."
  type        = number
  default     = 32768
}

variable "onprem_vm_disk_gb" {
  description = "Size in GiB for the primary disk attached to each in-house server."
  type        = number
  default     = 500
}

variable "onprem_vm_gateway" {
  description = "Default gateway used by provisioned servers."
  type        = string
  default     = ""
}

variable "onprem_vm_ipv4_prefix_length" {
  description = "IPv4 prefix length assigned to the management network for in-house servers."
  type        = number
  default     = 24
}

variable "onprem_dns_servers" {
  description = "DNS servers configured on provisioned servers."
  type        = list(string)
  default     = []
}

variable "onprem_vm_ip_addresses" {
  description = "Static IPv4 addresses assigned to provisioned servers."
  type        = list(string)
  default     = []
}

variable "enable_minio" {
  description = "Whether to deploy the private MinIO object storage tier."
  type        = bool
  default     = true
}

variable "minio_server" {
  description = "Endpoint of the MinIO control plane (used for bucket management)."
  type        = string
  default     = "https://minio.internal:9000"
}

variable "minio_use_ssl" {
  description = "Whether the MinIO endpoint expects HTTPS."
  type        = bool
  default     = true
}

variable "minio_access_key" {
  description = "Access key for interacting with the MinIO management API."
  type        = string
  default     = ""
  sensitive   = true
}

variable "minio_secret_key" {
  description = "Secret key for interacting with the MinIO management API."
  type        = string
  default     = ""
  sensitive   = true
}

variable "minio_release_name" {
  description = "Name of the Helm release used for MinIO."
  type        = string
  default     = "minio"
}

variable "minio_namespace" {
  description = "Namespace where MinIO should be deployed."
  type        = string
  default     = "storage"
}

variable "minio_chart_version" {
  description = "Version of the Bitnami MinIO Helm chart."
  type        = string
  default     = "14.6.15"
}

variable "minio_default_buckets" {
  description = "Default buckets to create within the MinIO deployment."
  type        = list(string)
  default     = ["corebank-ledger", "analytics-datalake"]
}

variable "minio_root_user" {
  description = "Root user configured for the MinIO server."
  type        = string
  default     = "minio-root"
}

variable "minio_root_password" {
  description = "Root password configured for the MinIO server."
  type        = string
  default     = ""
  sensitive   = true
}

variable "minio_persistence_size" {
  description = "Persistent volume size requested for MinIO."
  type        = string
  default     = "10Ti"
}

variable "minio_storage_class" {
  description = "StorageClass used for MinIO persistent volumes."
  type        = string
  default     = ""
}

variable "minio_service_type" {
  description = "Service type used to expose MinIO inside the cluster."
  type        = string
  default     = "ClusterIP"
}

variable "minio_distributed_mode" {
  description = "Whether MinIO should run in distributed mode."
  type        = bool
  default     = true
}

variable "minio_replica_count" {
  description = "Replica count supplied to the MinIO Helm chart."
  type        = number
  default     = 4
}

variable "minio_service_annotations" {
  description = "Additional annotations applied to the MinIO service."
  type        = map(string)
  default     = {}
}

variable "minio_ingress_enabled" {
  description = "Whether to expose MinIO via an ingress inside the private network."
  type        = bool
  default     = true
}

variable "minio_ingress_hostname" {
  description = "Hostname used by the MinIO ingress endpoint."
  type        = string
  default     = "minio.private.bank-web3"
}

variable "minio_ingress_annotations" {
  description = "Annotations applied to the MinIO ingress resource."
  type        = map(string)
  default     = {
    "kubernetes.io/ingress.class" = "nginx"
  }
}

variable "minio_ingress_tls_secret" {
  description = "Name of the TLS secret used for securing the MinIO ingress endpoint."
  type        = string
  default     = ""
}

variable "minio_extra_values" {
  description = "Additional Helm values merged into the MinIO release."
  type        = any
  default     = {}
}
