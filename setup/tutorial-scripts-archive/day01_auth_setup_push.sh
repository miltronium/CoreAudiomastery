#!/bin/bash

# Day 1 Authentication Setup and Push
# Core Audio Tutorial - Handle Git authentication and push Day 1 work

set -e

# Parse command line arguments
SSH_MODE=""
GITHUB_TOKEN=""
SKIP_AUTH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --ssh-existing)
            SSH_MODE="existing"
            shift
            ;;
        --ssh-new)
            SSH_MODE="new"
            shift
            ;;
        --token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        --skip-auth)
            SKIP_AUTH=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "OPTIONS:"
            echo "  --ssh-existing    Use existing SSH keys"
            echo "  --ssh-new         Generate new SSH keys"
            echo "  --token TOKEN     Use GitHub Personal Access Token"
            echo "  --skip-auth       Skip authentication setup (local only)"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --ssh-existing     # Use existing SSH keys"
            echo "  $0 --ssh-new          # Generate new SSH keys"
            echo "  $0 --token ghp_xxx    # Use specific token"
            echo "  $0 --skip-auth        # Local only, no remote push"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "======================================================================="
echo "[$(date '+%H:%M:%S')] 🔐 CORE AUDIO TUTORIAL - DAY 1 AUTH & PUSH"
echo "======================================================================="

if [[ -n "$SSH_MODE" ]]; then
    echo "🔑 SSH Mode: $SSH_MODE"
elif [[ -n "$GITHUB_TOKEN" ]]; then
    echo "🔑 Using provided GitHub token"
elif [[ "$SKIP_AUTH" == true ]]; then
    echo "⏭️  Skipping authentication (local only)"
else
    echo "🔑 Interactive authentication setup"
fi
echo

# Enhanced logging function
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    if [[ -n "$LOGS_DIR" && -d "$LOGS_DIR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-AUTH-PUSH] $1" >> "$LOGS_DIR/day01_session.log"
    fi
}

# Source environment
source_environment() {
    local env_paths=(
        "../.core-audio-env"
        "./.core-audio-env"
        "$HOME/Development/CoreAudio/.core-audio-env"
        "../../.core-audio-env"
    )
    
    for env_file in "${env_paths[@]}"; do
        if [[ -f "$env_file" ]]; then
            source "$env_file"
            return 0
        fi
    done
    return 1
}

# Check and fix authentication for a repository
fix_authentication() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_action "🔐 FIXING AUTHENTICATION FOR $repo_name"
    echo "========================================"
    
    cd "$repo_path"
    
    # Check if remote exists
    if ! git remote | grep -q "origin"; then
        echo "    ❌ No remote configured - skipping authentication setup"
        return 2
    fi
    
    # Get current remote URL
    CURRENT_URL=$(git remote get-url origin)
    echo "    📍 Current remote URL: $CURRENT_URL"
    
    # Analyze the URL and authentication issue
    echo "🔍 Analyzing authentication requirements..."
    
    if [[ "$CURRENT_URL" =~ ^https://github\.com/ ]]; then
        echo "    🌐 Detected GitHub repository"
        fix_github_auth "$repo_name" "$CURRENT_URL"
    elif [[ "$CURRENT_URL" =~ ^https://gitlab\.com/ ]]; then
        echo "    🌐 Detected GitLab repository"
        fix_gitlab_auth "$repo_name" "$CURRENT_URL"
    elif [[ "$CURRENT_URL" =~ ^https://bitbucket\.org/ ]]; then
        echo "    🌐 Detected Bitbucket repository"
        fix_bitbucket_auth "$repo_name" "$CURRENT_URL"
    elif [[ "$CURRENT_URL" =~ ^https:// ]]; then
        echo "    🌐 Detected HTTPS repository (generic)"
        fix_generic_https_auth "$repo_name" "$CURRENT_URL"
    elif [[ "$CURRENT_URL" =~ ^git@.*: ]]; then
        echo "    🔑 Detected SSH repository"
        fix_ssh_auth "$repo_name" "$CURRENT_URL"
    else
        echo "    ❓ Unknown repository type: $CURRENT_URL"
        fix_unknown_auth "$repo_name" "$CURRENT_URL"
    fi
    
    echo "========================================"
    echo
}

# GitHub authentication fix with command line options
fix_github_auth() {
    local repo_name="$1"
    local current_url="$2"
    
    echo
    echo "🔐 GitHub Authentication Setup for $repo_name"
    echo "============================================"
    
    # Check command line arguments first
    if [[ -n "$GITHUB_TOKEN" ]]; then
        echo "🔑 Using provided GitHub token"
        setup_github_token_direct "$repo_name" "$current_url" "$GITHUB_TOKEN"
        return $?
    elif [[ "$SSH_MODE" == "existing" ]]; then
        echo "🔑 Using existing SSH keys"
        setup_github_ssh_existing "$repo_name" "$current_url"
        return $?
    elif [[ "$SSH_MODE" == "new" ]]; then
        echo "🔑 Generating new SSH keys"
        setup_github_ssh_new "$repo_name" "$current_url"
        return $?
    elif [[ "$SKIP_AUTH" == true ]]; then
        echo "⏭️  Skipping authentication setup (local only)"
        return 2
    fi
    
    # Interactive mode if no command line args
    echo
    echo "The error 'Invalid username or token' means GitHub authentication failed."
    echo "GitHub requires either a Personal Access Token or SSH keys."
    echo
    echo "📋 Authentication Options:"
    echo "   1. Use existing SSH keys"
    echo "   2. Generate new SSH keys"
    echo "   3. Personal Access Token (HTTPS)"
    echo "   4. Skip push for now (work locally only)"
    echo
    
    read -p "Choose option (1/2/3/4): " auth_choice
    
    case "$auth_choice" in
        1)
            setup_github_ssh_existing "$repo_name" "$current_url"
            ;;
        2)
            setup_github_ssh_new "$repo_name" "$current_url"
            ;;
        3)
            setup_github_token "$repo_name" "$current_url"
            ;;
        4)
            echo "    ⏭️  Skipping authentication setup for $repo_name"
            return 2
            ;;
        *)
            echo "    ❌ Invalid choice"
            return 1
            ;;
    esac
}

# Setup GitHub Personal Access Token
setup_github_token() {
    local repo_name="$1"
    local current_url="$2"
    
    echo
    echo "🔑 Setting up GitHub Personal Access Token"
    echo "=========================================="
    echo
    echo "📋 Steps to create a Personal Access Token:"
    echo "   1. Go to: https://github.com/settings/tokens"
    echo "   2. Click 'Generate new token' > 'Generate new token (classic)'"
    echo "   3. Give it a name like 'Core Audio Tutorial'"
    echo "   4. Select expiration (90 days recommended)"
    echo "   5. Check these scopes:"
    echo "      ✅ repo (Full control of private repositories)"
    echo "      ✅ workflow (Update GitHub Action workflows)"
    echo "   6. Click 'Generate token'"
    echo "   7. Copy the token immediately (you won't see it again!)"
    echo
    echo "💡 The token looks like: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo
    
    read -p "Have you created a token and copied it? (y/n): " token_ready
    
    if [[ ! "$token_ready" =~ ^[Yy]$ ]]; then
        echo "    ⏭️  Please create the token first, then re-run this script"
        return 1
    fi
    
    echo
    read -s -p "Paste your GitHub Personal Access Token: " github_token
    echo
    
    if [[ -z "$github_token" ]]; then
        echo "    ❌ No token provided"
        return 1
    fi
    
    # Validate token format
    if [[ ! "$github_token" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
        echo "    ⚠️  Token format doesn't match expected GitHub format"
        echo "    Expected: ghp_ followed by 36 characters"
        echo "    Continuing anyway..."
    fi
    
    # Extract username and repo from URL
    if [[ "$current_url" =~ https://github\.com/([^/]+)/([^/]+)\.git ]]; then
        local username="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        
        echo "    📍 Detected GitHub user: $username"
        echo "    📍 Detected repository: $repo"
        
        # Create new URL with token
        local new_url="https://${username}:${github_token}@github.com/${username}/${repo}.git"
        
        echo "    🔄 Updating remote URL with token..."
        if git remote set-url origin "$new_url"; then
            echo "    ✅ Remote URL updated successfully"
            log_action "✅ Updated GitHub remote with token for $repo_name"
            return 0
        else
            echo "    ❌ Failed to update remote URL"
            return 1
        fi
    else
        echo "    ❌ Could not parse GitHub URL: $current_url"
        return 1
    fi
}

# Setup GitHub Personal Access Token directly (from command line)
setup_github_token_direct() {
    local repo_name="$1"
    local current_url="$2"
    local token="$3"
    
    echo "    🔑 Setting up GitHub with provided token"
    
    # Validate token format
    if [[ ! "$token" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
        echo "    ⚠️  Token format doesn't match expected GitHub format"
        echo "    Expected: ghp_ followed by 36 characters"
        echo "    Provided: ${token:0:10}..."
        echo "    Continuing anyway..."
    fi
    
    # Extract username and repo from URL
    if [[ "$current_url" =~ https://github\.com/([^/]+)/([^/]+)\.git ]]; then
        local username="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        
        echo "    📍 GitHub user: $username"
        echo "    📍 Repository: $repo"
        
        # Create new URL with token
        local new_url="https://${username}:${token}@github.com/${username}/${repo}.git"
        
        echo "    🔄 Updating remote URL with token..."
        if git remote set-url origin "$new_url"; then
            echo "    ✅ Remote URL updated successfully"
            log_action "✅ Updated GitHub remote with provided token for $repo_name"
            return 0
        else
            echo "    ❌ Failed to update remote URL"
            return 1
        fi
    else
        echo "    ❌ Could not parse GitHub URL: $current_url"
        return 1
    fi
}

# Setup GitHub SSH with existing keys
setup_github_ssh_existing() {
    local repo_name="$1"
    local current_url="$2"
    
    echo "    🔑 Setting up GitHub SSH with existing keys"
    
    # Check for existing SSH keys
    echo "    🔍 Checking for existing SSH keys..."
    
    local ssh_key_file=""
    local key_type=""
    
    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        ssh_key_file="$HOME/.ssh/id_ed25519.pub"
        key_type="ed25519"
        echo "    ✅ Found Ed25519 key: $ssh_key_file"
    elif [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
        ssh_key_file="$HOME/.ssh/id_rsa.pub"
        key_type="rsa"
        echo "    ✅ Found RSA key: $ssh_key_file"
    elif [[ -f "$HOME/.ssh/id_ecdsa.pub" ]]; then
        ssh_key_file="$HOME/.ssh/id_ecdsa.pub"
        key_type="ecdsa"
        echo "    ✅ Found ECDSA key: $ssh_key_file"
    else
        echo "    ❌ No SSH keys found in $HOME/.ssh/"
        echo "    Expected files: id_ed25519.pub, id_rsa.pub, or id_ecdsa.pub"
        echo "    Use --ssh-new to generate new keys"
        return 1
    fi
    
    # Test if key is already added to SSH agent
    echo "    🔍 Checking SSH agent..."
    if ssh-add -l | grep -q "$key_type"; then
        echo "    ✅ SSH key is loaded in agent"
    else
        echo "    🔄 Adding SSH key to agent..."
        local private_key="${ssh_key_file%.pub}"
        if ssh-add "$private_key" 2>/dev/null; then
            echo "    ✅ SSH key added to agent"
        else
            echo "    ⚠️  Could not add key to agent (may need passphrase)"
        fi
    fi
    
    # Convert HTTPS URL to SSH
    if [[ "$current_url" =~ https://github\.com/([^/]+)/([^/]+)\.git ]]; then
        local username="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        
        local ssh_url="git@github.com:${username}/${repo}.git"
        
        echo "    🔄 Converting to SSH URL: $ssh_url"
        
        if git remote set-url origin "$ssh_url"; then
            echo "    ✅ Remote URL updated to SSH"
            log_action "✅ Updated remote to SSH for $repo_name"
            
            # Test SSH connection
            echo "    🧪 Testing SSH connection to GitHub..."
            if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
                echo "    ✅ SSH authentication working!"
                return 0
            else
                echo "    ❌ SSH authentication failed"
                echo "    💡 You may need to add your SSH key to GitHub:"
                echo "       1. Copy your public key:"
                echo "          cat $ssh_key_file"
                echo "       2. Add it at: https://github.com/settings/keys"
                return 1
            fi
        else
            echo "    ❌ Failed to update remote URL"
            return 1
        fi
    else
        echo "    ❌ Could not parse GitHub URL: $current_url"
        return 1
    fi
}

# Setup GitHub SSH with new keys
setup_github_ssh_new() {
    local repo_name="$1"
    local current_url="$2"
    
    echo "    🔑 Generating new SSH keys for GitHub"
    
    # Get email for key generation
    echo "    📧 SSH key generation requires an email address"
    
    # Try to get git email first
    local git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_email" ]]; then
        echo "    📍 Found git email: $git_email"
        read -p "Use this email for SSH key? (y/n): " use_git_email
        
        if [[ "$use_git_email" =~ ^[Yy]$ ]]; then
            local email="$git_email"
        else
            read -p "Enter email for SSH key: " email
        fi
    else
        read -p "Enter email for SSH key: " email
    fi
    
    if [[ -z "$email" ]]; then
        echo "    ❌ Email required for SSH key generation"
        return 1
    fi
    
    # Generate SSH key
    echo "    🔑 Generating Ed25519 SSH key..."
    local key_file="$HOME/.ssh/id_ed25519_coreaudio"
    
    if ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""; then
        echo "    ✅ SSH key generated: $key_file"
        
        # Add to SSH agent
        if ssh-add "$key_file"; then
            echo "    ✅ SSH key added to agent"
        else
            echo "    ⚠️  Could not add key to agent"
        fi
        
        # Show public key and instructions
        echo
        echo "    📋 Add this SSH key to your GitHub account:"
        echo "       1. Go to: https://github.com/settings/keys"
        echo "       2. Click 'New SSH key'"
        echo "       3. Title: 'Core Audio Tutorial - $(hostname)'"
        echo "       4. Copy and paste this public key:"
        echo
        echo "    🔑 Your new SSH public key:"
        echo "    ========================================"
        cat "${key_file}.pub"
        echo "    ========================================"
        echo
        
        read -p "Have you added the SSH key to GitHub? (y/n): " ssh_added
        
        if [[ ! "$ssh_added" =~ ^[Yy]$ ]]; then
            echo "    ⏭️  Please add the SSH key first, then re-run with --ssh-existing"
            return 1
        fi
        
        # Convert to SSH URL and test
        return $(setup_github_ssh_existing "$repo_name" "$current_url")
        
    else
        echo "    ❌ Failed to generate SSH key"
        return 1
    fi
}

# Generic HTTPS authentication fix
fix_generic_https_auth() {
    local repo_name="$1"
    local current_url="$2"
    
    echo
    echo "🔐 Generic HTTPS Authentication"
    echo "=============================="
    echo
    echo "Your repository requires authentication but the exact method depends"
    echo "on your Git hosting service."
    echo
    echo "📋 Common solutions:"
    echo "   1. Personal Access Token (most services)"
    echo "   2. App Password (Bitbucket, some others)"
    echo "   3. SSH Keys (most secure)"
    echo "   4. Skip for now (local only)"
    echo
    
    read -p "Do you have credentials to use? (y/n): " has_creds
    
    if [[ "$has_creds" =~ ^[Yy]$ ]]; then
        echo
        read -p "Enter your username: " username
        read -s -p "Enter your token/password: " password
        echo
        
        # Update URL with credentials
        local protocol_and_domain=$(echo "$current_url" | sed 's|https://\(.*\)/.*|\1|')
        local path=$(echo "$current_url" | sed 's|https://[^/]*/\(.*\)|\1|')
        
        local new_url="https://${username}:${password}@${protocol_and_domain}/${path}"
        
        echo "    🔄 Updating remote URL with credentials..."
        if git remote set-url origin "$new_url"; then
            echo "    ✅ Remote URL updated"
            return 0
        else
            echo "    ❌ Failed to update remote URL"
            return 1
        fi
    else
        echo "    ⏭️  Skipping authentication setup"
        return 2
    fi
}

# SSH authentication fix
fix_ssh_auth() {
    local repo_name="$1"
    local current_url="$2"
    
    echo
    echo "🔑 SSH Authentication Issue"
    echo "=========================="
    echo
    echo "Your repository uses SSH but authentication failed."
    echo "This usually means:"
    echo "   1. SSH key not added to your Git hosting service"
    echo "   2. SSH key not loaded in SSH agent"
    echo "   3. Wrong SSH key being used"
    echo
    
    # Test SSH connection
    local hostname=$(echo "$current_url" | sed 's|git@\([^:]*\):.*|\1|')
    echo "🔍 Testing SSH connection to $hostname..."
    
    if ssh -T "git@$hostname" 2>&1 | grep -q "successfully authenticated"; then
        echo "    ✅ SSH authentication working"
        return 0
    else
        echo "    ❌ SSH authentication failed"
        echo
        echo "📋 Troubleshooting steps:"
        echo "   1. Check if SSH key is added to your Git hosting service"
        echo "   2. Run: ssh-add ~/.ssh/id_rsa (or your key file)"
        echo "   3. Test: ssh -T git@$hostname"
        echo
        return 1
    fi
}

# Unknown authentication fix
fix_unknown_auth() {
    local repo_name="$1"
    local current_url="$2"
    
    echo
    echo "❓ Unknown Repository Type"
    echo "========================"
    echo
    echo "Cannot automatically configure authentication for:"
    echo "   $current_url"
    echo
    echo "📋 Manual steps:"
    echo "   1. Check your Git hosting service documentation"
    echo "   2. Configure authentication manually"
    echo "   3. Or skip remote push for now"
    echo
    return 1
}

# Test push after authentication fix
test_push() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_action "🧪 Testing push for $repo_name after authentication fix"
    
    cd "$repo_path"
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    echo "    🚀 Attempting push: git push -u origin $CURRENT_BRANCH"
    
    if git push -u origin "$CURRENT_BRANCH"; then
        echo "    ✅ Push successful!"
        log_action "✅ Successfully pushed $repo_name after auth fix"
        return 0
    else
        echo "    ❌ Push still failed"
        log_action "❌ Push failed for $repo_name even after auth fix"
        return 1
    fi
}

# Main execution
source_environment || {
    log_action "❌ Cannot proceed without environment configuration"
    exit 1
}

log_action "🎯 Starting Day 1 authentication setup and push"

# Validate environment
if [[ -z "$CORE_AUDIO_ROOT" || -z "$TUTORIAL_ROOT" ]]; then
    log_action "❌ Environment variables not set"
    exit 1
fi

echo
echo "🔐 Git Authentication Setup and Push Workflow"
echo "============================================="
echo
echo "The error 'Invalid username or token' indicates that your Git hosting"
echo "service requires authentication, but the current setup isn't working."
echo
echo "This script will help you set up proper authentication and push your"
echo "Day 1 work to remote repositories."
echo

# =====================================================================
# 1. FIX AUTHENTICATION FOR BOTH REPOSITORIES
# =====================================================================

log_action "🔐 PHASE 1: FIXING AUTHENTICATION"
echo "=================================================================="
echo

CORE_AUTH_STATUS=1
TUTORIAL_AUTH_STATUS=1

# Fix CoreAudioMastery authentication
fix_authentication "$CORE_AUDIO_ROOT" "CoreAudioMastery"
CORE_AUTH_STATUS=$?

# Fix CoreAudioTutorial authentication
fix_authentication "$TUTORIAL_ROOT" "CoreAudioTutorial"
TUTORIAL_AUTH_STATUS=$?

# =====================================================================
# 2. TEST PUSH AFTER AUTHENTICATION FIX
# =====================================================================

log_action "🚀 PHASE 2: TESTING PUSH AFTER AUTHENTICATION FIX"
echo "=================================================================="
echo

PUSH_SUCCESS=true

# Test CoreAudioMastery push
if [[ $CORE_AUTH_STATUS -eq 0 ]]; then
    if ! test_push "$CORE_AUDIO_ROOT" "CoreAudioMastery"; then
        PUSH_SUCCESS=false
    fi
elif [[ $CORE_AUTH_STATUS -eq 2 ]]; then
    log_action "⏭️  CoreAudioMastery: Authentication setup skipped"
else
    log_action "❌ CoreAudioMastery: Authentication setup failed"
    PUSH_SUCCESS=false
fi

echo

# Test CoreAudioTutorial push
if [[ $TUTORIAL_AUTH_STATUS -eq 0 ]]; then
    if ! test_push "$TUTORIAL_ROOT" "CoreAudioTutorial"; then
        PUSH_SUCCESS=false
    fi
elif [[ $TUTORIAL_AUTH_STATUS -eq 2 ]]; then
    log_action "⏭️  CoreAudioTutorial: Authentication setup skipped"
else
    log_action "❌ CoreAudioTutorial: Authentication setup failed"
    PUSH_SUCCESS=false
fi

# =====================================================================
# 3. FINAL STATUS
# =====================================================================

echo
echo "======================================================================="

if [[ "$PUSH_SUCCESS" == true && ($CORE_AUTH_STATUS -eq 0 || $TUTORIAL_AUTH_STATUS -eq 0) ]]; then
    echo "✅ DAY 1 AUTHENTICATION AND PUSH SUCCESSFUL!"
    echo
    echo "🎉 Your Day 1 Core Audio Tutorial work has been successfully"
    echo "   pushed to remote repositories with proper authentication."
    echo
    echo "🚀 READY FOR DAY 2!"
    echo "   Run: ./day02_step01_shared_foundation.sh"
    
elif [[ $CORE_AUTH_STATUS -eq 2 && $TUTORIAL_AUTH_STATUS -eq 2 ]]; then
    echo "✅ DAY 1 LOCAL WORK COMPLETED!"
    echo
    echo "📝 Your work is saved locally (no remote push attempted)."
    echo "   You can set up remote repositories later if needed."
    echo
    echo "🚀 READY FOR DAY 2!"
    echo "   Run: ./day02_step01_shared_foundation.sh"
    
else
    echo "⚠️  DAY 1 PUSH ISSUES"
    echo
    echo "Authentication setup encountered issues."
    echo "Your work is still saved locally."
    echo
    echo "Options:"
    echo "   1. Continue with Day 2 (local development)"
    echo "   2. Fix authentication manually and retry"
    echo "   3. Set up remote repositories later"
fi

echo "======================================================================="

# Log completion
log_action "📅 Day 1 authentication and push workflow completed"

exit 0
