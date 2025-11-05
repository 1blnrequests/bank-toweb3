variable "vault_version" {
  description = "Version of the Vault Helm chart."
  type        = string
}

variable "k8s_namespace" {
  description = "Namespace where Vault will be installed."
  type        = string
}

variable "web3_namespace" {
  description = "Namespace that receives default Vault Agent configuration."
  type        = string
}
