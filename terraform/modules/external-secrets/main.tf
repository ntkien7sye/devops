data "aws_caller_identity" "current" {}

locals {
  oidc_issuer = replace(var.cluster_oidc_issuer_url, "https://", "")
}
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.9.11"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }
}
