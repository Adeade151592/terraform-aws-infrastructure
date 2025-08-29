# Terraform Infrastructure Module

This Terraform configuration creates a complete AWS infrastructure with VPC, EC2, and RDS using modular design and best practices.

## Architecture

- **VPC Module**: Creates VPC with public/private subnets, Internet Gateway, NAT Gateway
- **EC2 Module**: Deploys EC2 instance in public subnet with security groups
- **RDS Module**: Creates MySQL RDS instance in private subnets with restricted access

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. An existing AWS key pair for EC2 access

## Quick Start

### 1. Setup Remote State Backend

First, create the S3 bucket and DynamoDB table for remote state:

```bash
# Comment out the backend block in main.tf temporarily
terraform init
terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_state_lock
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize with Remote Backend

```bash
# Uncomment the backend block in main.tf
terraform init
```

### 4. Create Workspaces

```bash
# Create staging environment
terraform workspace new staging
terraform plan
terraform apply

# Create production environment
terraform workspace new production
terraform plan
terraform apply
```

## Workspace Management

This configuration supports multiple environments using Terraform workspaces:

- `staging`: Uses smaller instance types and CIDR 10.0.0.0/16
- `production`: Uses larger instance types and CIDR 10.1.0.0/16

Switch between workspaces:
```bash
terraform workspace select staging
terraform workspace select production
```

## Security Features

- EC2 instances in public subnets with restricted security groups
- RDS instances in private subnets, accessible only from EC2
- Encrypted RDS storage
- S3 bucket with versioning and encryption for state files
- DynamoDB state locking

## Outputs

After deployment, you'll get:
- VPC ID and CIDR
- Subnet IDs
- EC2 instance IP addresses
- RDS endpoint and port

## Cleanup

```bash
terraform workspace select staging
terraform destroy

terraform workspace select production
terraform destroy
```

## Design Choices

1. **Modular Design**: Separate modules for VPC, EC2, and RDS for reusability
2. **Environment Variables**: Using workspace-specific configurations
3. **Security**: Private subnets for RDS, security groups for traffic control
4. **State Management**: Remote state with locking for team collaboration
5. **Minimal Resources**: Cost-effective configuration suitable for development/testing

## File Structure

```
terraform-infrastructure/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── backend-setup.tf        # S3/DynamoDB setup
├── terraform.tfvars.example
├── modules/
│   ├── vpc/               # VPC module
│   ├── ec2/               # EC2 module
│   └── rds/               # RDS module
└── README.md
```