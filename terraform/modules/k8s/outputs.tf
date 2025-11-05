output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group protecting the control plane."
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group assigned to worker nodes."
  value       = aws_security_group.node.id
}
