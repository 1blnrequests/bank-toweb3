locals {
  name_prefix = "${var.environment}-web3"
}

module "network" {
  source   = "./modules/network"
  name     = local.name_prefix
  vpc_cidr = var.vpc_cidr
  subnets  = var.subnets
  tags     = var.tags
}

module "k8s" {
  source             = "./modules/k8s"
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  node_group         = var.eks_node_group
  tags               = var.tags
}

# Retrieve authentication material for the Kubernetes and Helm providers.
data "aws_eks_cluster" "this" {
  name = module.k8s.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.k8s.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "kubernetes_namespace" "web3" {
  metadata {
    name = var.web3_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                      = "web3"
    }
  }
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${module.k8s.cluster_name}/cluster"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${module.k8s.cluster_name}-control-plane"
  })
}

module "kafka" {
  source                     = "./modules/kafka"
  cluster_name               = var.kafka_cluster_name
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_cidr_blocks        = length(var.kafka_allowed_cidr_blocks) > 0 ? var.kafka_allowed_cidr_blocks : [var.vpc_cidr]
  broker_instance_type       = var.kafka_broker_instance_type
  number_of_broker_nodes     = var.kafka_number_of_broker_nodes
  ebs_volume_size            = var.kafka_ebs_volume_size
  enhanced_monitoring_level  = var.kafka_enhanced_monitoring
  tags                       = var.tags
}

module "vault" {
  source         = "./modules/vault"
  vault_version  = var.vault_version
  k8s_namespace  = var.vault_namespace
  web3_namespace = var.web3_namespace

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    kubernetes_namespace.web3
  ]
}

module "onprem_infrastructure" {
  count = var.enable_onprem_workloads ? 1 : 0

  source            = "./modules/onprem"
  datacenter        = var.vsphere_datacenter
  datastore         = var.vsphere_datastore
  resource_pool     = var.vsphere_resource_pool
  network           = var.vsphere_network
  template          = var.onprem_vm_template
  folder            = var.onprem_vm_folder
  hostname_prefix   = var.onprem_vm_hostname_prefix
  domain            = var.onprem_vm_domain
  vm_count          = var.onprem_vm_count
  cpu               = var.onprem_vm_cpu
  memory_mb         = var.onprem_vm_memory_mb
  disk_gb           = var.onprem_vm_disk_gb
  gateway           = var.onprem_vm_gateway
  dns_servers       = var.onprem_dns_servers
  ip_addresses      = var.onprem_vm_ip_addresses
  ipv4_prefix_length = var.onprem_vm_ipv4_prefix_length
  tags              = var.tags

  providers = {
    vsphere = vsphere
  }
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                      = "web3"
      "component"                     = "monitoring"
    }
  }
}

locals {
  observability_values = merge({
    grafana = {
      defaultDashboardsEnabled = true
      persistence = {
        enabled = true
        size    = "10Gi"
      }
      ingress = {
        enabled = true
        annotations = {
          "kubernetes.io/ingress.class" = "nginx"
        }
        hosts = [
          {
            host  = "grafana.${var.environment}.bank-web3.internal"
            paths = [{ path = "/", pathType = "Prefix" }]
          }
        ]
      }
    }
    prometheus = {
      prometheusSpec = {
        retention                    = "15d"
        retentionSize                = "150GiB"
        scrapeInterval               = "30s"
        externalLabels = {
          environment = var.environment
          platform    = "bank-web3"
        }
      }
    }
  }, try(var.prometheus_values, {}))
}

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_observability_stack ? 1 : 0

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.observability.metadata[0].name

  values = [yamlencode(local.observability_values)]

  timeout     = 600
  max_history = 3

  depends_on = [
    kubernetes_namespace.observability,
    module.k8s,
  ]
}

module "minio" {
  count = var.enable_minio ? 1 : 0

  source            = "./modules/minio"
  namespace         = var.minio_namespace
  release_name      = var.minio_release_name
  chart_version     = var.minio_chart_version
  root_user         = var.minio_root_user
  root_password     = var.minio_root_password
  default_buckets   = var.minio_default_buckets
  persistence_size  = var.minio_persistence_size
  storage_class     = var.minio_storage_class
  service_type      = var.minio_service_type
  distributed_mode  = var.minio_distributed_mode
  replica_count     = var.minio_replica_count
  ingress_enabled   = var.minio_ingress_enabled
  ingress_hostname  = var.minio_ingress_hostname
  ingress_annotations = var.minio_ingress_annotations
  ingress_tls_secret  = var.minio_ingress_tls_secret
  service_annotations = var.minio_service_annotations
  extra_values        = var.minio_extra_values

  providers = {
    helm       = helm
    kubernetes = kubernetes
    minio      = minio
  }

  depends_on = [
    module.k8s
  ]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  count = var.enable_observability_stack ? 1 : 0

  metadata {
    name      = "web3-platform-dashboards"
    namespace = kubernetes_namespace.observability.metadata[0].name
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    "web3-overview.json" = file("${path.module}/dashboards/web3-overview.json")
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}
