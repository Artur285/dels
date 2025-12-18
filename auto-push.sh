#!/bin/bash

# Automatic push script for dels repository
# This script will attempt to create and push the repository automatically

set -e

echo "🚀 Automatic GitHub Push for 'dels' repository"
echo ""

# Check if already has remote
if git remote get-url origin &>/dev/null; then
    echo "✅ Remote 'origin' already configured"
    REMOTE_URL=$(git remote get-url origin)
    echo "   Remote: $REMOTE_URL"
    echo ""
    echo "📤 Pushing to existing repository..."
    git push -u origin feature/enhanced-property-listings
    echo ""
    echo "✅ Successfully pushed!"
    exit 0
fi

# Try GitHub CLI first
if command -v gh &> /dev/null; then
    echo "🔍 Checking GitHub CLI authentication..."
    
    if gh auth status &>/dev/null 2>&1; then
        echo "✅ GitHub CLI authenticated"
        echo ""
        echo "📦 Creating repository 'dels' on GitHub..."
        
        # Try to create repo
        if gh repo create dels \
            --public \
            --description "Modern warehouse property listing platform with enhanced UI and animations" \
            --source=. \
            --remote=origin \
            --push 2>/dev/null; then
            echo ""
            echo "✅ Success! Repository created and pushed!"
            echo ""
            gh repo view dels --web
            exit 0
        else
            echo "⚠️  Repository might already exist, trying to add remote..."
            GITHUB_USER=$(gh api user -q .login 2>/dev/null || echo "")
            if [ -n "$GITHUB_USER" ]; then
                git remote add origin "https://github.com/$GITHUB_USER/dels.git" 2>/dev/null || \
                git remote set-url origin "https://github.com/$GITHUB_USER/dels.git"
                git push -u origin feature/enhanced-property-listings
                echo "✅ Successfully pushed to existing repository!"
                exit 0
            fi
        fi
    else
        echo "⚠️  GitHub CLI not authenticated"
    fi
fi

# Try with GitHub token if available
if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 Using GitHub token from environment..."
    GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$GITHUB_USER" ]; then
        echo "✅ Authenticated as: $GITHUB_USER"
        echo ""
        echo "📦 Creating repository..."
        
        # Create repo via API
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/user/repos \
            -d "{\"name\":\"dels\",\"description\":\"Modern warehouse property listing platform with enhanced UI and animations\",\"private\":false}")
        
        if echo "$RESPONSE" | grep -q '"name"'; then
            echo "✅ Repository created!"
        elif echo "$RESPONSE" | grep -q "already exists"; then
            echo "ℹ️  Repository already exists"
        else
            echo "⚠️  Could not create repository via API"
        fi
        
        # Add remote and push
        git remote add origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USER/dels.git" 2>/dev/null || \
        git remote set-url origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USER/dels.git"
        
        echo "📤 Pushing code..."
        git push -u origin feature/enhanced-property-listings
        
        echo ""
        echo "✅ Success! Repository: https://github.com/$GITHUB_USER/dels"
        exit 0
    fi
fi

# If we get here, we need manual setup
echo ""
echo "❌ Automatic push requires authentication"
echo ""
echo "Please choose one of these options:"
echo ""
echo "OPTION 1: Authenticate GitHub CLI"
echo "  gh auth login"
echo "  Then run this script again"
echo ""
echo "OPTION 2: Use Personal Access Token"
echo "  export GITHUB_TOKEN=your_token_here"
echo "  Then run this script again"
echo ""
echo "OPTION 3: Manual Setup"
echo "  1. Create repo at: https://github.com/new (name: dels)"
echo "  2. Run: git remote add origin https://github.com/YOUR_USERNAME/dels.git"
echo "  3. Run: git push -u origin feature/enhanced-property-listings"
echo ""
exit 1




