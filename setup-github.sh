#!/bin/bash

# Script to set up GitHub repository for DEL Properties project

echo "🚀 Setting up GitHub repository for DEL Properties..."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git not initialized. Please run 'git init' first."
    exit 1
fi

# Get repository name from current directory
REPO_NAME=$(basename "$(pwd)")

echo "Repository name: $REPO_NAME"
echo ""
echo "To create a GitHub repository, you have two options:"
echo ""
echo "OPTION 1: Using GitHub CLI (if installed)"
echo "  gh repo create $REPO_NAME --public --source=. --remote=origin --push"
echo ""
echo "OPTION 2: Manual setup"
echo "  1. Go to https://github.com/new"
echo "  2. Create a new repository named: $REPO_NAME"
echo "  3. Don't initialize with README, .gitignore, or license"
echo "  4. Then run these commands:"
echo ""
echo "     git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
echo "     git push -u origin feature/enhanced-property-listings"
echo ""
echo "OPTION 3: Using GitHub API (requires personal access token)"
echo "  If you have a GitHub personal access token, you can create the repo via API"
echo ""

# Check if user wants to proceed with API method
read -p "Do you have a GitHub personal access token? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your GitHub username: " GITHUB_USER
    read -sp "Enter your GitHub personal access token: " GITHUB_TOKEN
    echo ""
    read -p "Enter repository name (default: $REPO_NAME): " REPO_NAME_INPUT
    REPO_NAME=${REPO_NAME_INPUT:-$REPO_NAME}
    
    echo ""
    echo "Creating repository..."
    
    # Create repo via API
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO_NAME\",\"description\":\"Modern warehouse property listing platform with enhanced UI and animations\",\"private\":false}")
    
    if echo "$RESPONSE" | grep -q "already exists"; then
        echo "⚠️  Repository already exists. Adding remote..."
    elif echo "$RESPONSE" | grep -q "Bad credentials"; then
        echo "❌ Authentication failed. Please check your token."
        exit 1
    elif echo "$RESPONSE" | grep -q '"name"'; then
        echo "✅ Repository created successfully!"
    else
        echo "❌ Failed to create repository. Response:"
        echo "$RESPONSE"
        exit 1
    fi
    
    # Add remote and push
    echo ""
    echo "Adding remote origin..."
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || \
    git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    
    echo "Pushing to GitHub..."
    git push -u origin feature/enhanced-property-listings
    
    echo ""
    echo "✅ Done! Your repository is available at:"
    echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
fi

