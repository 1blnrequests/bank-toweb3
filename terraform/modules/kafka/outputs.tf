output "bootstrap_brokers_tls" {
  description = "TLS bootstrap brokers endpoint."
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "security_group_id" {
  description = "Security group protecting Kafka brokers."
  value       = aws_security_group.msk.id
}
