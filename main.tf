# Main Terraform configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# Local values for reusable computations
locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  
  vpc_cidr = var.environment_configs[terraform.workspace].vpc_cidr
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = local.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  public_subnet_cidrs  = var.environment_configs[terraform.workspace].public_subnet_cidrs
  private_subnet_cidrs = var.environment_configs[terraform.workspace].private_subnet_cidrs
  
  tags = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  instance_type        = var.environment_configs[terraform.workspace].instance_type
  key_pair_name        = var.key_pair_name
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_security_group = module.ec2.security_group_id
  db_instance_class  = var.environment_configs[terraform.workspace].db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  
  tags = local.common_tags
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}