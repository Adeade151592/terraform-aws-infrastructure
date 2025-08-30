# Run this first to create S3 bucket and DynamoDB table for remote state
# Comment out the backend block in main.tf when running this

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.state.arn
    }
  }
}

# KMS Key for state bucket encryption
resource "aws_kms_key" "state" {
  description         = "KMS key for Terraform state bucket encryption"
  enable_key_rotation = true
  
  tags = {
    Name        = "Terraform State Encryption Key"
    Environment = "shared"
  }
}

resource "aws_kms_alias" "state" {
  name          = "alias/terraform-state-${var.state_bucket_name}"
  target_key_id = aws_kms_key.state.key_id
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = length(var.state_lock_table_name) > 0 ? var.state_lock_table_name : "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "shared"
  }
}