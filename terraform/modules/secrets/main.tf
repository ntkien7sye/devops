
resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.name_prefix}/database-credentials"
  description             = "Database credentials for ${var.name_prefix}"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-secret"
  })
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    host     = var.database_endpoint
    port     = var.database_port
    database = var.database_name
    username = var.database_username
    password = var.database_password
    url      = "postgresql://${var.database_username}:${var.database_password}@${var.database_endpoint}/${var.database_name}"
  })
}
resource "aws_secretsmanager_secret" "slack_webhook" {
  name                    = "${var.name_prefix}/slack-webhook"
  description             = "Slack webhook URL for notifications"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-slack-webhook-secret"
  })
}

resource "aws_secretsmanager_secret_version" "slack_webhook" {
  secret_id = aws_secretsmanager_secret.slack_webhook.id
  secret_string = jsonencode({
    webhook_url = var.slack_webhook_url
  })
}
resource "random_password" "jwt_access_secret" {
  length  = 64
  special = false
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.name_prefix}/app-secrets"
  description             = "Application secrets for ${var.name_prefix}"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-secrets"
  })
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    JWT_ACCESS_TOKEN_SECRET_KEY   = random_password.jwt_access_secret.result
    JWT_ACCESS_TOKEN_EXPIRED_IN   = "86400"
    JWT_REFRESH_TOKEN_SECRET_KEY  = random_password.jwt_refresh_secret.result
    JWT_REFRESH_TOKEN_EXPIRED_IN  = "604800"
  })
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "secrets_access" {
  name        = "${var.name_prefix}-secrets-access-policy"
  description = "Policy to allow access to secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.database.arn,
          aws_secretsmanager_secret.slack_webhook.arn,
          aws_secretsmanager_secret.app_secrets.arn
        ]
      }
    ]
  })

  tags = var.tags
}
locals {
  oidc_issuer = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.name_prefix}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  policy_arn = aws_iam_policy.secrets_access.arn
  role       = aws_iam_role.external_secrets.name
}
