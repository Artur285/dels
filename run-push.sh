#!/bin/bash
# One-command push solution

echo "🚀 Pushing dels to GitHub..."
echo ""

# Check authentication
if ! gh auth status &>/dev/null 2>&1; then
    echo "📋 Authentication required. Choose one:"
    echo ""
    echo "Option 1: Interactive (recommended)"
    echo "  gh auth login"
    echo "  ./quick-push.sh"
    echo ""
    echo "Option 2: Use token"
    echo "  export GITHUB_TOKEN=your_token"
    echo "  ./auto-push.sh"
    echo ""
    echo "Option 3: Manual"
    echo "  1. Create repo at: https://github.com/new (name: dels)"
    echo "  2. git remote add origin https://github.com/YOUR_USERNAME/dels.git"
    echo "  3. git push -u origin feature/enhanced-property-listings"
    exit 1
fi

# If authenticated, push automatically
echo "✅ Authenticated! Pushing..."
./quick-push.sh
