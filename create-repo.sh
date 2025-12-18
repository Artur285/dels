#!/bin/bash

# Script to create GitHub repository for DEL Properties

REPO_NAME="dels"
GITHUB_USER="Artur_b124"

echo "🚀 Creating GitHub repository: $REPO_NAME"
echo ""

# Check if already authenticated
if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI is authenticated!"
    echo ""
    echo "Creating repository..."
    gh repo create "$REPO_NAME" --public --source=. --remote=origin --description "Modern warehouse property listing platform with enhanced UI and animations" --push
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Repository created and pushed successfully!"
        echo "📍 Repository URL: https://github.com/$GITHUB_USER/$REPO_NAME"
        echo "🌿 Branch: feature/enhanced-property-listings"
    else
        echo "❌ Failed to create repository. It might already exist."
        echo "Trying to add remote and push..."
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null
        git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null
        git push -u origin feature/enhanced-property-listings
    fi
else
    echo "⚠️  Not authenticated with GitHub CLI"
    echo ""
    echo "Please authenticate first by running:"
    echo "  gh auth login"
    echo ""
    echo "Then run this script again, or manually:"
    echo "  gh repo create $REPO_NAME --public --source=. --remote=origin --push"
    echo ""
    echo "Or create the repository manually at:"
    echo "  https://github.com/new"
    echo ""
    echo "Then run:"
    echo "  git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "  git push -u origin feature/enhanced-property-listings"
fi




