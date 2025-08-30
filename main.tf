# Main Terraform configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-unique-suffix"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for reusable computations
locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  
  # Validate workspace exists in configuration
  workspace_config = try(var.environment_configs[terraform.workspace], null)
  
  # Extract workspace values with defaults using try()
  vpc_cidr              = try(local.workspace_config.vpc_cidr, "10.0.0.0/16")
  public_subnet_cidrs   = try(local.workspace_config.public_subnet_cidrs, ["10.0.1.0/24", "10.0.2.0/24"])
  private_subnet_cidrs  = try(local.workspace_config.private_subnet_cidrs, ["10.0.10.0/24", "10.0.20.0/24"])
  instance_type         = try(local.workspace_config.instance_type, "t3.micro")
  db_instance_class     = try(local.workspace_config.db_instance_class, "db.t3.micro")
  
  # Calculate max subnet count for availability zones
  max_subnet_count      = max(length(local.public_subnet_cidrs), length(local.private_subnet_cidrs))
}

# Security Module
module "security" {
  source = "./modules/security"
  
  project_name = var.project_name
  tags         = local.common_tags
}

# Secrets Module
module "secrets" {
  source = "./modules/secrets"
  
  project_name = var.project_name
  db_username  = var.db_username
  db_password  = var.db_password
  api_key      = "temp-api-key-1234567890"
  jwt_secret   = "temp-jwt-secret-1234567890123456789012345678901234567890"
  tags         = local.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
  secrets_arn  = module.secrets.app_secret_arn
  tags         = local.common_tags
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr              = local.vpc_cidr
  availability_zones    = slice(data.aws_availability_zones.available.names, 0, local.max_subnet_count)
  public_subnet_cidrs   = local.public_subnet_cidrs
  private_subnet_cidrs  = local.private_subnet_cidrs
  flow_logs_role_arn    = module.iam.flow_logs_role_arn
  flow_logs_group_arn   = module.security.vpc_flow_logs_group_arn
  
  tags = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_subnet_ids      = module.vpc.private_subnet_ids
  instance_type           = local.instance_type
  instance_profile_name   = module.iam.ec2_instance_profile_name
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_security_group = module.ec2.security_group_id
  db_instance_class  = local.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_secret_arn      = module.secrets.db_secret_arn
  
  tags = local.common_tags
}