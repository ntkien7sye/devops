output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.database.arn
}

output "database_secret_name" {
  description = "Name of the database credentials secret"
  value       = aws_secretsmanager_secret.database.name
}

output "slack_webhook_secret_arn" {
  description = "ARN of the Slack webhook secret"
  value       = aws_secretsmanager_secret.slack_webhook.arn
}

output "slack_webhook_secret_name" {
  description = "Name of the Slack webhook secret"
  value       = aws_secretsmanager_secret.slack_webhook.name
}

output "app_secrets_arn" {
  description = "ARN of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "app_secrets_name" {
  description = "Name of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "secrets_access_policy_arn" {
  description = "ARN of the secrets access policy"
  value       = aws_iam_policy.secrets_access.arn
}

output "external_secrets_role_arn" {
  description = "ARN of the External Secrets IAM role"
  value       = aws_iam_role.external_secrets.arn
}
