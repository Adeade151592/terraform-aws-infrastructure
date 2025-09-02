# Additional security hardening configurations

# Security-focused variables
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access ALB (empty list allows all)"
  type        = list(string)
  default     = []
}

# Security group for restricted access
resource "aws_security_group" "restricted_alb" {
  count       = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  name_prefix = "${var.project_name}-restricted-alb-"
  description = "Restricted ALB access to specific CIDR blocks"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      description = "HTTP/HTTPS from allowed CIDRs"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-restricted-alb-sg"
  }
}

# CloudWatch Dashboard for security monitoring
# Note: Dashboard will be created after ALB deployment