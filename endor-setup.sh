#!/bin/bash

# Endor Labs Setup Script
echo "🔧 Setting up Endor Labs integration..."

# Check if endorctl is installed
if ! command -v ~/.local/bin/endorctl &> /dev/null; then
    echo "❌ Endor Labs CLI not found. Installing..."
    mkdir -p ~/.local/bin
    curl -O -L https://api.endorlabs.com/download/latest/endorctl_macos_amd64
    chmod +x endorctl_macos_amd64
    mv endorctl_macos_amd64 ~/.local/bin/endorctl
    echo "✅ Endor Labs CLI installed"
else
    echo "✅ Endor Labs CLI already installed"
fi

# Initialize Endor Labs (requires API credentials)
echo "🔑 To complete setup, you need Endor Labs API credentials:"
echo "1. Sign up at https://app.endorlabs.com"
echo "2. Get your API key and secret"
echo "3. Set environment variables:"
echo "   export ENDOR_API_KEY='your-api-key'"
echo "   export ENDOR_API_SECRET='your-api-secret'"
echo "   export ENDOR_NAMESPACE='your-namespace'"
echo ""
echo "4. Run: ~/.local/bin/endorctl auth login"
echo ""
echo "📋 For GitHub Actions, add these secrets:"
echo "   - ENDOR_API_KEY"
echo "   - ENDOR_API_SECRET" 
echo "   - ENDOR_NAMESPACE"
echo ""
echo "🚀 Once configured, run: bash run-sast.sh"