resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.k8s_namespace
    labels = {
      "app.kubernetes.io/name" = "vault"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_version
  namespace  = kubernetes_namespace.vault.metadata[0].name

  values = [
    yamlencode({
      global = {
        enabled = true
      }
      injector = {
        enabled = true
      }
      server = {
        ha = {
          enabled = false
        }
        dataStorage = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp3"
        }
        auditStorage = {
          enabled      = true
          size         = "5Gi"
          storageClass = "gp3"
        }
        ingress = {
          enabled = false
        }
        extraEnvironmentVars = {
          VAULT_API_ADDR = "http://vault.${var.k8s_namespace}.svc:8200"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.vault]
}

resource "kubernetes_config_map" "vault_agent_defaults" {
  metadata {
    name      = "vault-agent-config"
    namespace = var.web3_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "component"                     = "vault-agent"
    }
  }

  data = {
    "agent-config.hcl" = <<-EOT
      exit_after_auth = false
      pid_file        = "/home/vault/pid"

      auto_auth {
        method "kubernetes" {
          mount_path = "auth/kubernetes"
          config = {
            role = "web3-app"
          }
        }

        sink "file" {
          config = {
            path = "/home/vault/.vault-token"
          }
        }
      }

      template {
        destination = "/vault/secrets/application.env"
        contents    = <<EOH
    export VAULT_TOKEN="{{ with secret \"secret/data/platform/web3\" }}{{ .Data.data.token }}{{ end }}"
    export MPC_ENDPOINT="{{ with secret \"secret/data/platform/mpc\" }}{{ .Data.data.endpoint }}{{ end }}"
    EOH
      }
    EOT
  }
}
