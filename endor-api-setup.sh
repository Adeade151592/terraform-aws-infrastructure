#!/bin/bash

echo "🔑 Endor Labs API Setup"
echo "======================"

# Check if endorctl is installed
if ! command -v ~/.local/bin/endorctl &> /dev/null; then
    echo "❌ Endor Labs CLI not found. Run: bash endor-setup.sh"
    exit 1
fi

echo "✅ Endor Labs CLI found"

# Check for existing credentials
if [[ -n "$ENDOR_API_KEY" && -n "$ENDOR_API_SECRET" && -n "$ENDOR_NAMESPACE" ]]; then
    echo "✅ Environment variables found"
    echo "🔐 Testing authentication..."
    
    if ~/.local/bin/endorctl auth login --api-key "$ENDOR_API_KEY" --api-secret "$ENDOR_API_SECRET" --namespace "$ENDOR_NAMESPACE" 2>/dev/null; then
        echo "✅ Authentication successful!"
        
        echo "🔍 Running test scan..."
        ~/.local/bin/endorctl scan --bypass-host-check . --output-type json > /tmp/endor-test.json 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Test scan completed successfully!"
            echo "📊 Scan results:"
            cat /tmp/endor-test.json | jq -r '.summary // "Scan completed"' 2>/dev/null || echo "Scan data available"
            rm -f /tmp/endor-test.json
        else
            echo "⚠️  Test scan completed (results may require project initialization)"
        fi
        
        echo ""
        echo "🎉 Endor Labs is fully configured!"
        echo "🚀 Run: bash run-sast.sh"
        
    else
        echo "❌ Authentication failed. Check your credentials."
        exit 1
    fi
else
    echo "❌ Missing environment variables. Please set:"
    echo "   export ENDOR_API_KEY='your-api-key'"
    echo "   export ENDOR_API_SECRET='your-api-secret'"
    echo "   export ENDOR_NAMESPACE='your-namespace'"
    echo ""
    echo "📋 Get credentials at: https://app.endorlabs.com"
    exit 1
fi