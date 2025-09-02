.PHONY: security-scan install-tools validate plan apply destroy

# Install SAST tools
install-tools:
	@echo "Installing SAST security tools..."
	brew install pipx || echo "pipx already installed"
	pipx install semgrep || echo "semgrep already installed"
	pip install checkov
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
	brew install tflint || echo "tflint installation failed"
	@echo "Installing Endor Labs CLI..."
	mkdir -p ~/.local/bin
	curl -O -L https://api.endorlabs.com/download/latest/endorctl_macos_amd64
	chmod +x endorctl_macos_amd64
	mv endorctl_macos_amd64 ~/.local/bin/endorctl

# Run comprehensive security scan
security-scan:
	@echo "Running Terraform security scans..."
	@echo "=== Checkov Scan ==="
	checkov -d . --framework terraform --output cli
	@echo "=== TFSec Scan ==="
	tfsec . --format table
	@echo "=== TFLint Scan ==="
	tflint --init && tflint
	@echo "=== Semgrep Scan ==="
	semgrep --config=p/terraform --config=p/secrets .
	@echo "=== Endor Labs Scan ==="
	~/.local/bin/endorctl scan --bypass-host-check . || echo "Endor Labs scan requires API credentials"

# Terraform operations with security checks
validate: security-scan
	terraform fmt -check
	terraform validate

plan: validate
	terraform plan -out=tfplan

apply: plan
	terraform apply tfplan

destroy:
	terraform destroy -auto-approve