variable "project_name" {
  description = "Name of the project"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}