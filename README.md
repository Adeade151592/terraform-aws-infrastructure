# Secure DevOps Infrastructure

Enterprise-grade AWS infrastructure with comprehensive security controls.

## 🏗️ Architecture

- **VPC**: Multi-AZ with public/private subnets
- **Security**: KMS encryption, CloudTrail, Config, VPC Flow Logs
- **Compute**: Auto Scaling EC2 instances with ALB
- **Database**: RDS with encryption and automated backups
- **Monitoring**: CloudWatch alarms and SNS notifications
- **Secrets**: AWS Secrets Manager integration

## 🔐 Security Features

- ✅ All data encrypted at rest and in transit
- ✅ Network segmentation with security groups
- ✅ Comprehensive logging and monitoring
- ✅ AWS Config compliance rules
- ✅ Secrets management with rotation
- ✅ IAM roles with least privilege

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Bash shell

### Deployment

1. **Clone and setup:**
   ```bash
   git clone <your-repo>
   cd terraform-infrastructure
   ```

2. **Configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy securely:**
   ```bash
   ./deploy.sh
   ```

### Environment Variables

Set sensitive variables via environment:

```bash
export TF_VAR_db_password="your-secure-password"
export TF_VAR_state_bucket_name="your-unique-bucket-name"
```

## 📁 Project Structure

```
├── modules/
│   ├── vpc/          # VPC and networking
│   ├── security/     # Security services (CloudTrail, Config)
│   ├── ec2/          # Compute resources
│   ├── rds/          # Database
│   ├── iam/          # IAM roles and policies
│   └── secrets/      # Secrets Manager
├── main.tf           # Main configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output values
├── terraform.tfvars.example  # Example variables
└── deploy.sh         # Secure deployment script
```

## 🔒 Security Best Practices

### Git Security
- ✅ `terraform.tfvars` excluded from Git
- ✅ `backend.hcl` excluded from Git
- ✅ State files excluded from Git
- ✅ Sensitive values via environment variables

### AWS Security
- ✅ Remote state with encryption and locking
- ✅ KMS keys for all encryption
- ✅ VPC Flow Logs enabled
- ✅ CloudTrail for API logging
- ✅ Config for compliance monitoring

## 🛠️ Manual Commands

If you prefer manual deployment:

```bash
# Initialize
terraform init -backend-config=backend.hcl

# Plan
terraform plan

# Apply
terraform apply

# Destroy (when needed)
terraform destroy
```

## 📊 Outputs

After deployment, you'll get:
- VPC and subnet IDs
- Load balancer DNS name
- Security monitoring ARNs
- Database endpoint (sensitive)

## 🆘 Troubleshooting

### Common Issues

1. **Backend not found**: Ensure S3 bucket and DynamoDB table exist
2. **Permission denied**: Check AWS credentials and permissions
3. **Resource conflicts**: Ensure unique naming across regions

### Support

Check AWS CloudTrail and Config for detailed logs of any issues.

## 🔄 Updates

To update infrastructure:
1. Modify Terraform files
2. Run `./deploy.sh`
3. Review plan carefully before applying

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

**⚠️ Warning**: This will delete all infrastructure including data!