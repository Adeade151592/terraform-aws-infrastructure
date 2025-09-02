#!/bin/bash

echo "🚀 Secure Infrastructure Deployment"
echo "==================================="

# Pre-deployment security scan
echo "🔒 Running pre-deployment security scan..."
bash run-sast.sh

# Check for critical issues
if ! bash run-sast.sh | grep -q "Checkov: Passed checks: 5, Failed checks: 0"; then
    echo "❌ Security scan failed. Fix issues before deployment."
    exit 1
fi

echo "✅ Security scan passed"

# Set required environment variables
export TF_VAR_db_password=$(openssl rand -base64 32)
export TF_VAR_api_key=$(openssl rand -base64 32)
export TF_VAR_jwt_secret=$(openssl rand -base64 32)

echo "🔑 Generated secure passwords"
echo "Password: $TF_VAR_db_password"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Create workspace
echo "📁 Creating staging workspace..."
terraform workspace new staging 2>/dev/null || terraform workspace select staging

# Deploy with auto-approve
echo "🚀 Deploying infrastructure..."
terraform apply -auto-approve

echo "✅ Deployment complete!"
echo "🔍 Run 'terraform output' to see connection details"