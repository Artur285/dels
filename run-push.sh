#!/bin/bash

# Combined script to authenticate and push

echo "🚀 Setting up automatic push to GitHub..."
echo ""

# Check if already authenticated
if gh auth status &>/dev/null 2>&1; then
    echo "✅ Already authenticated!"
    echo ""
    echo "📤 Pushing to GitHub..."
    ./quick-push.sh
    exit $?
fi

echo "🔐 Authentication required"
echo ""
echo "Starting GitHub authentication..."
echo "This will open your browser..."
echo ""

# Start auth process
gh auth login --web --hostname github.com

# Wait a moment for auth to complete
sleep 2

# Check if auth was successful
if gh auth status &>/dev/null 2>&1; then
    echo ""
    echo "✅ Authentication successful!"
    echo ""
    echo "📤 Pushing to GitHub..."
    ./quick-push.sh
else
    echo ""
    echo "⚠️  Authentication not completed. Please run:"
    echo "   gh auth login"
    echo "   Then run: ./quick-push.sh"
    exit 1
fi
