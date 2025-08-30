variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_username) >= 3
    error_message = "Database username must be at least 3 characters long."
  }
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "api_key" {
  description = "Application API key"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.api_key) >= 16
    error_message = "API key must be at least 16 characters long."
  }
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "JWT secret must be at least 32 characters long."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}