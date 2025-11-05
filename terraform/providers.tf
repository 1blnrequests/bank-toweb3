terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 1.17"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(
      {
        Environment = var.environment
        Project     = "web3-banking-platform"
      },
      var.tags,
    )
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.vsphere_allow_unverified_ssl
}

provider "minio" {
  minio_server   = var.minio_server
  minio_user     = var.minio_access_key != "" ? var.minio_access_key : var.minio_root_user
  minio_password = var.minio_secret_key != "" ? var.minio_secret_key : var.minio_root_password
  ssl            = var.minio_use_ssl
}

# The Kubernetes and Helm providers are configured after the EKS control plane is created.
# See terraform/main.tf for the data sources that supply the credentials.
