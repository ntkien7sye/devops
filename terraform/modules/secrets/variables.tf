variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "database_endpoint" {
  description = "Database endpoint"
  type        = string
}

variable "database_port" {
  description = "Database port"
  type        = number
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack webhook URL"
  type        = string
  sensitive   = true
}

variable "eks_cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for EKS cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "ARN of EKS node IAM role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
