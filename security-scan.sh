#!/bin/bash

# Terraform SAST Security Scanner
set -e

echo "🔒 Starting Terraform Security Scan..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install tools if not present
install_tools() {
    echo "📦 Installing SAST tools..."
    
    if ! command_exists checkov; then
        pip install checkov
    fi
    
    if ! command_exists tfsec; then
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    fi
    
    if ! command_exists tflint; then
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    fi
}

# Run Checkov scan
run_checkov() {
    echo -e "${YELLOW}🔍 Running Checkov scan...${NC}"
    if command_exists checkov; then
        checkov -d . --framework terraform --output cli --compact
    else
        echo -e "${RED}❌ Checkov not found${NC}"
        return 1
    fi
}

# Run TFSec scan
run_tfsec() {
    echo -e "${YELLOW}🔍 Running TFSec scan...${NC}"
    if command_exists tfsec; then
        tfsec . --format table
    else
        echo -e "${RED}❌ TFSec not found${NC}"
        return 1
    fi
}

# Run TFLint scan
run_tflint() {
    echo -e "${YELLOW}🔍 Running TFLint scan...${NC}"
    if command_exists tflint; then
        tflint --init
        tflint
    else
        echo -e "${RED}❌ TFLint not found${NC}"
        return 1
    fi
}

# Main execution
main() {
    if [[ "$1" == "--install" ]]; then
        install_tools
    fi
    
    echo "🚀 Running security scans on Terraform code..."
    
    # Run all scans
    run_checkov
    echo ""
    run_tfsec
    echo ""
    run_tflint
    
    echo -e "${GREEN}✅ Security scan completed!${NC}"
}

main "$@"