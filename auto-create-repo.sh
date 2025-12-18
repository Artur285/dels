#!/bin/bash

# Automated GitHub repository creation script
set -e

REPO_NAME="dels"
GITHUB_USER="Artur285"
BRANCH="feature/enhanced-property-listings"

echo "🚀 Automated GitHub Repository Creation"
echo "========================================"
echo ""

# Function to create repo via API
create_repo_api() {
    local token=$1
    echo "Creating repository via GitHub API..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO_NAME\",\"description\":\"Modern warehouse property listing platform with enhanced UI and animations\",\"private\":false}")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "201" ]; then
        echo "✅ Repository created successfully!"
        return 0
    elif [ "$http_code" = "422" ]; then
        if echo "$body" | grep -q "already exists"; then
            echo "⚠️  Repository already exists, continuing..."
            return 0
        fi
    fi
    
    echo "❌ Failed to create repository. HTTP Code: $http_code"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    return 1
}

# Function to setup remote and push
setup_and_push() {
    echo ""
    echo "Setting up remote and pushing code..."
    
    # Remove existing remote if any
    git remote remove origin 2>/dev/null || true
    
    # Add remote
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    
    # Push branch
    echo "Pushing branch: $BRANCH"
    git push -u origin "$BRANCH"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Success! Repository is live at:"
        echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
        echo "   Branch: $BRANCH"
        return 0
    else
        echo "❌ Failed to push. Please check your authentication."
        return 1
    fi
}

# Try GitHub CLI first
echo "Step 1: Checking GitHub CLI authentication..."
if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI is authenticated!"
    echo ""
    echo "Creating repository with GitHub CLI..."
    
    if gh repo create "$REPO_NAME" --public --source=. --remote=origin --description "Modern warehouse property listing platform with enhanced UI and animations" --push 2>/dev/null; then
        echo ""
        echo "✅ Repository created and pushed successfully!"
        echo "📍 https://github.com/$GITHUB_USER/$REPO_NAME"
        exit 0
    else
        # Repo might exist, try to setup remote and push
        echo "Repository might already exist, setting up remote..."
        setup_and_push
        exit $?
    fi
fi

# Try GitHub token from environment
echo "GitHub CLI not authenticated. Checking for token..."
if [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ Found GITHUB_TOKEN environment variable"
    create_repo_api "$GITHUB_TOKEN"
    setup_and_push
    exit $?
fi

# Try to get token from keychain (macOS)
echo "Checking macOS keychain for GitHub token..."
token=$(security find-generic-password -a "$GITHUB_USER" -s github.com -w 2>/dev/null | head -1)
if [ -n "$token" ] && [ "$token" != "" ]; then
    echo "✅ Found token in keychain"
    create_repo_api "$token"
    setup_and_push
    exit $?
fi

# Try to authenticate with GitHub CLI non-interactively
echo ""
echo "Attempting to authenticate GitHub CLI..."
echo "This will open a browser window for authentication."

# Try device flow
code=$(gh auth login --web --hostname github.com 2>&1 | grep -oE '[A-Z0-9]{4}-[A-Z0-9]{4}' | head -1)

if [ -n "$code" ]; then
    echo ""
    echo "📋 Please complete authentication:"
    echo "   1. Open: https://github.com/login/device"
    echo "   2. Enter code: $code"
    echo "   3. Authorize the application"
    echo ""
    echo "Waiting for authentication (30 seconds)..."
    
    # Wait a bit for user to authenticate
    sleep 30
    
    # Check if authenticated now
    if gh auth status &>/dev/null; then
        echo "✅ Authentication successful!"
        gh repo create "$REPO_NAME" --public --source=. --remote=origin --description "Modern warehouse property listing platform" --push
        exit $?
    fi
fi

# Fallback: Manual instructions
echo ""
echo "❌ Could not authenticate automatically."
echo ""
echo "Please run these commands manually:"
echo ""
echo "  1. Authenticate:"
echo "     gh auth login"
echo ""
echo "  2. Create and push:"
echo "     gh repo create $REPO_NAME --public --source=. --remote=origin --push"
echo ""
echo "Or set GITHUB_TOKEN environment variable:"
echo "     export GITHUB_TOKEN=your_token_here"
echo "     ./auto-create-repo.sh"
echo ""
exit 1

