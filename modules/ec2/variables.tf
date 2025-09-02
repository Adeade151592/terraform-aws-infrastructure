variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC identifier starting with 'vpc-'."
  }
}

locals {
  subnet_id_pattern = "^subnet-[0-9a-f]{8,17}$"
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
  
  validation {
    condition     = length(var.public_subnet_ids) > 0 && alltrue([for id in var.public_subnet_ids : can(regex(local.subnet_id_pattern, id))])
    error_message = "Public subnet IDs must be valid AWS subnet identifiers starting with 'subnet-'."
  }
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
  
  validation {
    condition     = length(var.private_subnet_ids) > 0 && alltrue([for id in var.private_subnet_ids : can(regex(local.subnet_id_pattern, id))])
    error_message = "Private subnet IDs must be valid AWS subnet identifiers starting with 'subnet-'."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
  
  validation {
    condition     = length(var.instance_profile_name) > 0
    error_message = "Instance profile name cannot be empty."
  }
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener (optional)"
  type        = string
  default     = null
  
  validation {
    condition     = var.ssl_certificate_arn == null || can(regex("^arn:aws:acm:[^:]+:[^:]+:certificate/.+$", var.ssl_certificate_arn))
    error_message = "SSL certificate ARN must be a valid ACM certificate ARN or null."
  }
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "internal_alb" {
  description = "Whether to make ALB internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Enable WAF protection for ALB"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}