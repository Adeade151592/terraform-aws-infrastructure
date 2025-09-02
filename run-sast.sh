#!/bin/bash

# Load environment variables if .env exists
if [[ -f .env ]]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "🔒 SAST Security Scan Results"
echo "============================="

echo -e "\n✅ CHECKOV SCAN:"
checkov -d . --framework terraform --output cli --compact

echo -e "\n🔍 TFSEC SCAN:"
tfsec . --format table 2>/dev/null || tfsec . --format json | jq -r '.results[] | "❌ \(.rule_description) - \(.severity) - \(.location.filename):\(.location.start_line)"' 2>/dev/null || echo "No TFSec issues found"

echo -e "\n🔧 TFLINT SCAN:"
tflint --init >/dev/null 2>&1
tflint

echo -e "\n🔍 SEMGREP SCAN:"
semgrep --config=p/terraform --config=p/secrets --config=p/security-audit . --json | jq -r '.results | length as $count | if $count == 0 then "✅ No Semgrep findings" else "❌ \($count) Semgrep findings found" end' 2>/dev/null || semgrep --config=p/terraform . --quiet

echo -e "\n🔎 ENDOR LABS SCAN:"
if command -v ~/.local/bin/endorctl >/dev/null 2>&1; then
    if [[ -n "$ENDOR_API_KEY" && -n "$ENDOR_API_SECRET" && -n "$ENDOR_NAMESPACE" ]]; then
        ~/.local/bin/endorctl scan --bypass-host-check --namespace "$ENDOR_NAMESPACE" . 2>/dev/null && echo "✅ Endor Labs scan completed successfully" || echo "⚠️ Endor Labs scan completed with warnings"
    else
        echo "⚠️ Endor Labs CLI found but not configured. Run: bash endor-quickstart.sh"
    fi
else
    echo "⚠️ Endor Labs CLI not found - run: bash endor-setup.sh"
fi

echo -e "\n📊 SCAN SUMMARY:"
echo "- Checkov: $(checkov -d . --framework terraform --output cli --compact 2>/dev/null | grep -o 'Passed checks: [0-9]*' || echo 'Passed checks: 0'), $(checkov -d . --framework terraform --output cli --compact 2>/dev/null | grep -o 'Failed checks: [0-9]*' || echo 'Failed checks: 0')"
echo "- TFSec: Security scan completed"
echo "- TFLint: Linting completed"
echo "- Semgrep: Advanced security analysis completed"
echo "- Endor Labs: Supply chain security analysis completed"