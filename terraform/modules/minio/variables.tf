variable "namespace" {
  description = "Namespace where the MinIO chart is installed."
  type        = string
}

variable "release_name" {
  description = "Helm release name for MinIO."
  type        = string
}

variable "chart_version" {
  description = "Version of the MinIO Helm chart."
  type        = string
}

variable "root_user" {
  description = "Root username for the MinIO deployment."
  type        = string
}

variable "root_password" {
  description = "Root password for the MinIO deployment."
  type        = string
  sensitive   = true
}

variable "default_buckets" {
  description = "List of default buckets to provision when MinIO starts."
  type        = list(string)
  default     = []
}

variable "persistence_size" {
  description = "Persistent volume claim size requested for MinIO."
  type        = string
}

variable "storage_class" {
  description = "StorageClass used for MinIO persistent volume claims."
  type        = string
  default     = ""
}

variable "service_type" {
  description = "Kubernetes service type used to expose MinIO."
  type        = string
  default     = "ClusterIP"
}

variable "distributed_mode" {
  description = "Whether MinIO should run in distributed mode."
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Number of MinIO replicas. The chart will multiply this by 4 drives when in distributed mode."
  type        = number
  default     = 4
}

variable "ingress_enabled" {
  description = "Whether to create an ingress for private MinIO access."
  type        = bool
  default     = true
}

variable "ingress_hostname" {
  description = "Hostname exposed by the ingress."
  type        = string
  default     = ""
}

variable "ingress_annotations" {
  description = "Annotations applied to the MinIO ingress resource."
  type        = map(string)
  default     = {}
}

variable "ingress_tls_secret" {
  description = "TLS secret used by the ingress controller."
  type        = string
  default     = ""
}

variable "service_annotations" {
  description = "Annotations applied to the MinIO service."
  type        = map(string)
  default     = {}
}

variable "extra_values" {
  description = "Additional raw Helm values to merge into the MinIO release."
  type        = any
  default     = {}
}
