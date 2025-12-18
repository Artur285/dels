#!/bin/bash

# Script to push dels project to GitHub

echo "🚀 Pushing dels to GitHub..."
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ Username is required"
    exit 1
fi

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    echo "⚠️  Remote 'origin' already exists. Updating..."
    git remote set-url origin "https://github.com/$GITHUB_USER/dels.git"
else
    echo "➕ Adding remote origin..."
    git remote add origin "https://github.com/$GITHUB_USER/dels.git"
fi

echo ""
echo "📤 Pushing to GitHub..."
git push -u origin feature/enhanced-property-listings

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! Your repository is available at:"
    echo "   https://github.com/$GITHUB_USER/dels"
    echo ""
    echo "Branch: feature/enhanced-property-listings"
else
    echo ""
    echo "❌ Push failed. Make sure:"
    echo "   1. The repository 'dels' exists on GitHub"
    echo "   2. You have the correct permissions"
    echo "   3. You're authenticated with GitHub"
fi




