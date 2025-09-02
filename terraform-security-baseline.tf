# Security baseline configurations for Terraform

# S3 bucket security baseline
resource "aws_s3_bucket_public_access_block" "security_baseline" {
  count  = var.enable_security_baseline ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "security_baseline" {
  count  = var.enable_security_baseline ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudTrail for audit logging
resource "aws_cloudtrail" "security_audit" {
  count                         = var.enable_security_baseline ? 1 : 0
  name                          = "${var.project_name}-security-audit"
  s3_bucket_name               = aws_s3_bucket.terraform_state.id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.security_audit[0].arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs[0].arn
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  enable_log_file_validation   = true
  kms_key_id                   = aws_kms_key.cloudtrail[0].arn

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
  }
}

# KMS Key for CloudTrail encryption
resource "aws_kms_key" "cloudtrail" {
  count                   = var.enable_security_baseline ? 1 : 0
  description             = "KMS key for CloudTrail log encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = {
    Name = "${var.project_name}-cloudtrail-key"
  }
}

resource "aws_kms_alias" "cloudtrail" {
  count         = var.enable_security_baseline ? 1 : 0
  name          = "alias/${var.project_name}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "security_audit" {
  count             = var.enable_security_baseline ? 1 : 0
  name              = "/aws/cloudtrail/${var.project_name}-security-audit"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cloudtrail[0].arn
}

# IAM Role for CloudTrail CloudWatch Logs
resource "aws_iam_role" "cloudtrail_logs" {
  count = var.enable_security_baseline ? 1 : 0
  name  = "${var.project_name}-security-audit-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  count = var.enable_security_baseline ? 1 : 0
  name  = "${var.project_name}-security-audit-logs-policy"
  role  = aws_iam_role.cloudtrail_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.security_audit[0].arn}:*"
      }
    ]
  })
}

# Security group baseline - no wide open access
resource "aws_security_group" "baseline_sg" {
  count       = var.enable_security_baseline ? 1 : 0
  name_prefix = "${var.project_name}-baseline-"
  description = "Security baseline - restrictive access"
  vpc_id      = module.vpc.vpc_id

  # No ingress rules by default - must be explicitly added
  
  # No egress rules by default - must be explicitly added

  tags = {
    Name = "${var.project_name}-baseline-sg"
  }
}