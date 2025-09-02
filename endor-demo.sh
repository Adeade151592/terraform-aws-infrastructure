#!/bin/bash

echo "🔎 Endor Labs Demo Mode"
echo "======================"

# Set demo environment variables
export ENDOR_API_KEY="demo-key"
export ENDOR_API_SECRET="demo-secret"
export ENDOR_NAMESPACE="demo-namespace"

echo "✅ Demo credentials set"
echo "🔍 Running SAST scan with Endor Labs integration..."

# Run the security scan
bash run-sast.sh

echo ""
echo "🎉 Demo complete!"
echo "📋 To use real Endor Labs functionality:"
echo "   1. Sign up at https://app.endorlabs.com"
echo "   2. Get API credentials"
echo "   3. Run: bash endor-quickstart.sh"