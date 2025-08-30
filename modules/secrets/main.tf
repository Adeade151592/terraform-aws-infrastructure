# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for ${var.project_name} secrets encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager to use the key"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = var.tags
}

data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project_name}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# Database credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials"
  description             = "Database credentials for ${var.project_name}"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 30

  tags = var.tags
}

# Secret version should be managed externally to avoid storing in Terraform state
# Use AWS CLI or external tools to populate secret values:
# aws secretsmanager put-secret-value --secret-id <secret-arn> --secret-string '{"username":"admin","password":"secure-password"}'

# Application secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}-app-secrets"
  description             = "Application secrets for ${var.project_name}"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 30

  tags = var.tags
}

# Secret version should be managed externally to avoid storing in Terraform state
# Use AWS CLI or external tools to populate secret values:
# aws secretsmanager put-secret-value --secret-id <secret-arn> --secret-string '{"api_key":"key","jwt_secret":"secret"}'