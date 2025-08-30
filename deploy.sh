#!/bin/bash

# Secure Terraform Deployment Script
# This script handles sensitive variables securely

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Secure Terraform Deployment${NC}"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${RED}❌ Please update terraform.tfvars with your values and run again${NC}"
    exit 1
fi

# Check if backend.hcl exists
if [ ! -f "backend.hcl" ]; then
    echo -e "${YELLOW}⚠️  backend.hcl not found. Creating from example...${NC}"
    cat > backend.hcl << EOF
# Backend configuration - DO NOT commit to Git
bucket         = "terraform-state-bucket-unique-suffix"
key            = "terraform.tfstate"
region         = "us-east-1"
encrypt        = true
EOF
    echo -e "${RED}❌ Please update backend.hcl with your S3 bucket name${NC}"
    exit 1
fi

# Set sensitive variables via environment if not provided
if [ -z "$TF_VAR_db_password" ]; then
    echo -e "${YELLOW}🔐 Enter database password (will be hidden):${NC}"
    read -s TF_VAR_db_password
    export TF_VAR_db_password
fi

# Initialize Terraform
echo -e "${GREEN}🔧 Initializing Terraform...${NC}"
terraform init -backend-config=backend.hcl

# Plan deployment
echo -e "${GREEN}📋 Planning deployment...${NC}"
terraform plan

# Ask for confirmation
echo -e "${YELLOW}🤔 Do you want to apply these changes? (yes/no):${NC}"
read -r response
if [[ "$response" == "yes" ]]; then
    echo -e "${GREEN}🚀 Applying changes...${NC}"
    terraform apply -auto-approve
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
else
    echo -e "${YELLOW}❌ Deployment cancelled${NC}"
fi