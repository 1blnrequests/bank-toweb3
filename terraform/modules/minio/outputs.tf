output "namespace" {
  description = "Namespace where MinIO is deployed."
  value       = kubernetes_namespace.minio.metadata[0].name
}

output "release_name" {
  description = "Helm release name for MinIO."
  value       = helm_release.minio.name
}

output "default_buckets" {
  description = "Buckets provisioned during the MinIO bootstrap phase."
  value       = var.default_buckets
}

output "bucket_ids" {
  description = "Identifiers returned by the MinIO provider for managed buckets."
  value       = { for name, bucket in minio_s3_bucket.managed : name => bucket.id }
}
