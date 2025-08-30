variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "secrets_arn" {
  description = "ARN of the secrets manager secret"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:[a-zA-Z0-9/_+=.@-]+$", var.secrets_arn))
    error_message = "Secrets ARN must be a valid AWS Secrets Manager ARN."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}