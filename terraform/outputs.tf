output "vpc_id" {
  description = "Identifier of the provisioned VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Identifiers of public subnets available for ingress components."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Identifiers of private subnets used by the platform workloads."
  value       = module.network.private_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.k8s.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS control plane."
  value       = module.k8s.cluster_endpoint
}

output "kafka_brokers" {
  description = "TLS bootstrap brokers for the MSK cluster."
  value       = module.kafka.bootstrap_brokers_tls
}

output "vault_address" {
  description = "Internal service address for Vault."
  value       = module.vault.vault_address
}

output "observability_namespace" {
  description = "Namespace dedicated to monitoring components."
  value       = kubernetes_namespace.observability.metadata[0].name
}

output "grafana_dashboard_config_map" {
  description = "Name of the ConfigMap providing Web3 dashboards for Grafana."
  value       = try(kubernetes_config_map.grafana_dashboards[0].metadata[0].name, null)
}

output "onprem_hostnames" {
  description = "Hostnames allocated to the in-house workload nodes."
  value       = var.enable_onprem_workloads ? module.onprem_infrastructure[0].hostnames : []
}

output "onprem_ip_addresses" {
  description = "Static IPv4 addresses assigned to the in-house workload nodes."
  value       = var.enable_onprem_workloads ? module.onprem_infrastructure[0].ip_addresses : []
}

output "minio_namespace" {
  description = "Namespace where the private MinIO object storage tier is deployed."
  value       = var.enable_minio ? module.minio[0].namespace : null
}

output "minio_default_buckets" {
  description = "Buckets created during the bootstrap of the private MinIO deployment."
  value       = var.enable_minio ? module.minio[0].default_buckets : []
}

output "minio_bucket_ids" {
  description = "Identifiers assigned to MinIO buckets managed through IaC."
  value       = var.enable_minio ? module.minio[0].bucket_ids : {}
}
