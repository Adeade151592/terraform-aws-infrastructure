variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-infrastructure"
  
  validation {
    condition     = length(var.project_name) > 0 && can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must be non-empty and contain only alphanumeric characters and hyphens."
  }
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name)) && length(var.db_name) <= 64
    error_message = "Database name must start with a letter, contain only alphanumeric characters and underscores, and be max 64 characters."
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "dbadmin"
  
  validation {
    condition     = length(var.db_username) > 0
    error_message = "Database username cannot be empty."
  }
}

variable "db_password" {
  description = "Database password - set via environment variable TF_VAR_db_password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8 && can(regex("[A-Z]", var.db_password)) && can(regex("[a-z]", var.db_password)) && can(regex("[0-9]", var.db_password))
    error_message = "Database password must be at least 8 characters long and contain uppercase, lowercase, and numeric characters."
  }
}

variable "environment_configs" {
  description = "Environment-specific configurations"
  type = map(object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    instance_type        = string
    db_instance_class    = string
  }))
  
  validation {
    condition = length(var.environment_configs) > 0
    error_message = "At least one environment configuration must be provided."
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.state_bucket_name)) && length(var.state_bucket_name) >= 3 && length(var.state_bucket_name) <= 63
    error_message = "S3 bucket name must be 3-63 characters, lowercase, start/end with alphanumeric, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "state_lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "api_key" {
  description = "Application API key - set via environment variable TF_VAR_api_key"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.api_key) >= 16
    error_message = "API key must be at least 16 characters long."
  }
}

variable "jwt_secret" {
  description = "JWT secret key - set via environment variable TF_VAR_jwt_secret"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "JWT secret must be at least 32 characters long."
  }
}

variable "enable_security_baseline" {
  description = "Enable security baseline configurations (CloudTrail, S3 encryption, etc.)"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable WAF protection for ALB"
  type        = bool
  default     = true
}