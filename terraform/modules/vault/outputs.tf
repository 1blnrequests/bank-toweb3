output "vault_address" {
  description = "Cluster internal address for Vault API."
  value       = "http://vault.${var.k8s_namespace}.svc:8200"
}

output "namespace" {
  description = "Namespace where Vault is deployed."
  value       = kubernetes_namespace.vault.metadata[0].name
}
