output "namespace" {
  description = "Namespace where External Secrets is installed"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}
