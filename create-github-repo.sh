#!/bin/bash

# Script to create and push dels repository to GitHub

echo "🚀 Creating GitHub repository 'dels'..."
echo ""

# Check authentication
if ! gh auth status &>/dev/null; then
    echo "🔐 You need to authenticate with GitHub first."
    echo "   Run: gh auth login"
    echo "   Then run this script again."
    echo ""
    echo "   Or use the manual method below."
    exit 1
fi

# Create the repository
echo "📦 Creating repository 'dels' on GitHub..."
gh repo create dels \
    --public \
    --description "Modern warehouse property listing platform with enhanced UI and animations" \
    --source=. \
    --remote=origin \
    --push

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! Repository created and pushed!"
    echo ""
    echo "Repository URL:"
    gh repo view dels --web
else
    echo ""
    echo "❌ Failed to create repository. It might already exist."
    echo "   Trying to add remote and push instead..."
    
    # Get username
    GITHUB_USER=$(gh api user -q .login)
    
    if [ -n "$GITHUB_USER" ]; then
        git remote add origin "https://github.com/$GITHUB_USER/dels.git" 2>/dev/null || \
        git remote set-url origin "https://github.com/$GITHUB_USER/dels.git"
        
        git push -u origin feature/enhanced-property-listings
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully pushed to existing repository!"
        fi
    fi
fi

