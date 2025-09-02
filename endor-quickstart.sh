#!/bin/bash

echo "🚀 Endor Labs Quick Start"
echo "========================="

# Step 1: Check installation
if ! command -v ~/.local/bin/endorctl &> /dev/null; then
    echo "📦 Installing Endor Labs CLI..."
    bash endor-setup.sh
fi

# Step 2: Prompt for credentials if not set
if [[ -z "$ENDOR_API_KEY" ]]; then
    echo ""
    echo "🔑 Enter your Endor Labs credentials:"
    echo "   (Get them from: https://app.endorlabs.com)"
    echo ""
    read -p "API Key: " ENDOR_API_KEY
    read -s -p "API Secret: " ENDOR_API_SECRET
    echo ""
    read -p "Namespace: " ENDOR_NAMESPACE
    
    # Save to .env file
    cat > .env << EOF
ENDOR_API_KEY=$ENDOR_API_KEY
ENDOR_API_SECRET=$ENDOR_API_SECRET
ENDOR_NAMESPACE=$ENDOR_NAMESPACE
EOF
    
    echo "✅ Credentials saved to .env"
    export ENDOR_API_KEY ENDOR_API_SECRET ENDOR_NAMESPACE
fi

# Step 3: Test authentication
echo "🔐 Testing authentication..."
if ~/.local/bin/endorctl auth login --api-key "$ENDOR_API_KEY" --api-secret "$ENDOR_API_SECRET" --namespace "$ENDOR_NAMESPACE" 2>/dev/null; then
    echo "✅ Authentication successful!"
    
    # Step 4: Run initial scan
    echo "🔍 Running initial scan..."
    ~/.local/bin/endorctl scan --bypass-host-check . 2>/dev/null && echo "✅ Scan completed!"
    
    echo ""
    echo "🎉 Endor Labs is ready!"
    echo "🔧 Run full SAST scan: bash run-sast.sh"
    
else
    echo "❌ Authentication failed. Check credentials at https://app.endorlabs.com"
fi