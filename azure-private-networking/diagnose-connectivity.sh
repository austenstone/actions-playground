#!/bin/bash
# Diagnostic script to test GitHub Actions connectivity from Azure VNET

echo "======================================"
echo "GitHub Actions VNET Connectivity Test"
echo "======================================"
echo ""

# Test DNS resolution
echo "🔍 Testing DNS resolution..."
echo "---"
nslookup github.com
nslookup api.github.com
nslookup pipelines.actions.githubusercontent.com
echo ""

# Test HTTPS connectivity to critical domains
echo "🌐 Testing HTTPS connectivity..."
echo "---"

test_url() {
    local url=$1
    echo -n "Testing $url... "
    if curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" | grep -q "200\|301\|302"; then
        echo "✅ SUCCESS"
    else
        echo "❌ FAILED"
    fi
}

test_url "https://github.com"
test_url "https://api.github.com"
test_url "https://pipelines.actions.githubusercontent.com"
test_url "https://codeload.github.com"
test_url "https://results-receiver.actions.githubusercontent.com"
test_url "https://objects.githubusercontent.com"
test_url "https://github-releases.githubusercontent.com"
echo ""

# Test specific GitHub IP ranges
echo "📍 Testing GitHub IP connectivity (140.82.112.0/20)..."
echo "---"
curl -v --max-time 10 https://140.82.112.1 2>&1 | head -20
echo ""

# Check routing
echo "🚦 Checking route to github.com..."
echo "---"
traceroute -m 10 github.com 2>&1 || echo "traceroute not available"
echo ""

# Check if running in Azure
echo "☁️  Azure Metadata Service Test..."
echo "---"
curl -s -H "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq '.' || echo "Not running in Azure or metadata blocked"
echo ""

echo "======================================"
echo "Diagnostic complete!"
echo "======================================"
