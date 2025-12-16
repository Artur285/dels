#!/bin/bash
# Quick push after authentication
gh repo create dels --public --description "Modern warehouse property listing platform" --source=. --remote=origin --push || {
    GITHUB_USER=$(gh api user -q .login 2>/dev/null)
    if [ -n "$GITHUB_USER" ]; then
        git remote add origin "https://github.com/$GITHUB_USER/dels.git" 2>/dev/null
        git push -u origin feature/enhanced-property-listings
    fi
}
