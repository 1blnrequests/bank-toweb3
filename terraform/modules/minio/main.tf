locals {
  ingress_tls = var.ingress_tls_secret == "" ? [] : [
    {
      hosts      = [var.ingress_hostname]
      secretName = var.ingress_tls_secret
    }
  ]

  minio_values = merge({
    mode = var.distributed_mode ? "distributed" : "standalone"
    auth = {
      rootUser     = var.root_user
      rootPassword = var.root_password
    }
    defaultBuckets = length(var.default_buckets) > 0 ? join(",", var.default_buckets) : ""
    persistence = {
      enabled      = true
      size         = var.persistence_size
      storageClass = var.storage_class
    }
    service = {
      type         = var.service_type
      annotations  = var.service_annotations
      port         = 9000
      consolePort  = 9001
      nodePorts    = {
        api     = ""
        console = ""
      }
    }
    statefulset = {
      replicaCount = var.replica_count
    }
    ingress = {
      enabled     = var.ingress_enabled
      hostname    = var.ingress_hostname
      annotations = var.ingress_annotations
      tls         = local.ingress_tls
    }
  }, var.extra_values)
}

resource "kubernetes_namespace" "minio" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "minio"
      "app.kubernetes.io/managed-by" = "terraform"
      "tier"                         = "storage"
    }
  }
}

resource "helm_release" "minio" {
  name       = var.release_name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = var.chart_version
  namespace  = kubernetes_namespace.minio.metadata[0].name

  values = [yamlencode(local.minio_values)]

  timeout     = 600
  max_history = 5

  depends_on = [
    kubernetes_namespace.minio
  ]
}

resource "minio_s3_bucket" "managed" {
  for_each = { for bucket in var.default_buckets : bucket => bucket }

  bucket = each.value
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    helm_release.minio
  ]
}
