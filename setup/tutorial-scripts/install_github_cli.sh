#!/bin/bash

# GitHub CLI Installation and Setup Script
# Automates installation and authentication of GitHub CLI

set -e

echo "[$(date '+%H:%M:%S')] 🚀 GitHub CLI Installation and Setup"
echo "=================================================="

# Function for logging
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Detect operating system
detect_os() {
    log_action "🔍 Detecting operating system"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_action "✅ Detected: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_action "✅ Detected: Linux"
    else
        OS="unknown"
        log_action "⚠️  Detected: $OSTYPE (may need manual installation)"
    fi
}

# Check if Homebrew is available (macOS)
check_homebrew() {
    if command -v brew &> /dev/null; then
        log_action "✅ Homebrew found: $(brew --version | head -1)"
        return 0
    else
        log_action "❌ Homebrew not found"
        return 1
    fi
}

# Install GitHub CLI on macOS
install_macos() {
    log_action "🍺 Installing GitHub CLI on macOS"
    
    if check_homebrew; then
        log_action "📦 Installing via Homebrew"
        brew install gh
        log_action "✅ GitHub CLI installed via Homebrew"
    else
        log_action "❌ Homebrew required for easy installation"
        log_action "💡 Install Homebrew first:"
        log_action "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        log_action "   Then run this script again"
        return 1
    fi
}

# Install GitHub CLI on Linux
install_linux() {
    log_action "🐧 Installing GitHub CLI on Linux"
    
    # Detect Linux distribution
    if command -v apt &> /dev/null; then
        log_action "📦 Installing via apt (Debian/Ubuntu)"
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    elif command -v yum &> /dev/null; then
        log_action "📦 Installing via yum (CentOS/RHEL)"
        sudo dnf install 'dnf-command(config-manager)'
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo dnf install gh
    elif command -v pacman &> /dev/null; then
        log_action "📦 Installing via pacman (Arch Linux)"
        sudo pacman -S github-cli
    else
        log_action "❌ Could not detect package manager"
        log_action "💡 Manual installation required"
        log_action "   See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        return 1
    fi
    
    log_action "✅ GitHub CLI installed on Linux"
}

# Install GitHub CLI
install_github_cli() {
    log_action "🔧 Installing GitHub CLI"
    
    case $OS in
        "macos")
            install_macos
            ;;
        "linux")
            install_linux
            ;;
        *)
            log_action "❌ Unsupported OS for automatic installation"
            log_action "💡 Manual installation required"
            log_action "   See: https://cli.github.com/"
            return 1
            ;;
    esac
}

# Check if GitHub CLI is already installed
check_github_cli() {
    log_action "🔍 Checking for existing GitHub CLI installation"
    
    if command -v gh &> /dev/null; then
        log_action "✅ GitHub CLI already installed: $(gh --version | head -1)"
        return 0
    else
        log_action "❌ GitHub CLI not found - installation needed"
        return 1
    fi
}

# Authenticate with GitHub
authenticate_github() {
    log_action "🔐 Setting up GitHub authentication"
    
    if gh auth status &> /dev/null; then
        log_action "✅ Already authenticated with GitHub"
        log_action "   User: $(gh api user --jq .login 2>/dev/null || echo 'Unknown')"
        return 0
    else
        log_action "🔑 Starting GitHub authentication process"
        log_action "💡 Choose your preferred authentication method when prompted:"
        log_action "   • SSH (recommended for development)"
        log_action "   • HTTPS with token"
        
        echo
        gh auth login
        
        if gh auth status &> /dev/null; then
            log_action "✅ GitHub authentication successful"
            log_action "   User: $(gh api user --jq .login)"
            return 0
        else
            log_action "❌ GitHub authentication failed"
            return 1
        fi
    fi
}

# Test GitHub CLI functionality
test_github_cli() {
    log_action "🧪 Testing GitHub CLI functionality"
    
    # Test basic API access
    if gh api user &> /dev/null; then
        log_action "✅ GitHub API access working"
    else
        log_action "❌ GitHub API access failed"
        return 1
    fi
    
    # Test repository detection if in git repo
    if git remote get-url origin &> /dev/null; then
        local origin_url=$(git remote get-url origin)
        if [[ "$origin_url" =~ github\.com ]]; then
            log_action "✅ GitHub repository detected"
            if gh repo view &> /dev/null; then
                log_action "✅ Repository access confirmed"
            else
                log_action "⚠️  Repository access limited (may be private)"
            fi
        else
            log_action "ℹ️  Not in a GitHub repository"
        fi
    else
        log_action "ℹ️  Not in a git repository"
    fi
    
    log_action "✅ GitHub CLI functionality test complete"
}

# Create quick reference guide
create_reference_guide() {
    log_action "📄 Creating GitHub CLI quick reference"
    
    cat > "GITHUB_CLI_REFERENCE.md" << 'REF_EOF'
# GitHub CLI Quick Reference

## Installation Complete ✅
GitHub CLI (gh) is now installed and authenticated.

## Common Commands

### Issues
```bash
# Create an issue
gh issue create --title "Issue title" --body "Issue description"

# List issues
gh issue list

# View an issue
gh issue view 123

# Close an issue
gh issue close 123
```

### Repository
```bash
# View repository
gh repo view

# Clone a repository
gh repo clone owner/repo

# Create a repository
gh repo create repo-name
```

### Authentication
```bash
# Check auth status
gh auth status

# Login again if needed
gh auth login

# Logout
gh auth logout
```

### Pull Requests
```bash
# Create a PR
gh pr create --title "PR title" --body "PR description"

# List PRs
gh pr list

# View a PR
gh pr view 123
```

## Help System
```bash
# Get help for any command
gh help
gh issue help
gh repo help
```

## Next Steps
You can now use the `create_github_issue.sh` script to automatically create
the help system enhancement issue!

## Documentation
- Official docs: https://cli.github.com/manual/
- GitHub CLI repo: https://github.com/cli/cli
REF_EOF

    log_action "✅ Reference guide created: GITHUB_CLI_REFERENCE.md"
}

# Main execution
main() {
    log_action "🎯 Starting GitHub CLI installation and setup"
    
    # Detect OS
    detect_os
    
    # Check if already installed
    if check_github_cli; then
        log_action "ℹ️  GitHub CLI already installed, proceeding to authentication"
    else
        # Install GitHub CLI
        if ! install_github_cli; then
            log_action "❌ GitHub CLI installation failed"
            exit 1
        fi
        
        # Verify installation
        if ! check_github_cli; then
            log_action "❌ GitHub CLI installation verification failed"
            exit 1
        fi
    fi
    
    # Authenticate with GitHub
    if ! authenticate_github; then
        log_action "❌ GitHub authentication failed"
        exit 1
    fi
    
    # Test functionality
    if ! test_github_cli; then
        log_action "⚠️  GitHub CLI may have limited functionality"
    fi
    
    # Create reference guide
    create_reference_guide
    
    # Final status
    echo
    log_action "🎉 GitHub CLI Setup Complete!"
    log_action "✅ GitHub CLI installed and authenticated"
    log_action "✅ Ready to create issues and manage repositories"
    log_action "📄 Quick reference: GITHUB_CLI_REFERENCE.md"
    echo
    log_action "🚀 Next Steps:"
    log_action "   1. Run: ./create_github_issue.sh"
    log_action "   2. Continue with Day 2 tutorial implementation"
    echo
    log_action "💡 Test your setup: gh auth status"
}

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'HELP_EOF'
install_github_cli.sh - Install and setup GitHub CLI

USAGE:
    ./install_github_cli.sh

DESCRIPTION:
    Automatically installs GitHub CLI (gh) and sets up authentication.
    Supports macOS (via Homebrew) and Linux (via package managers).

FEATURES:
    - Detects operating system automatically
    - Installs via system package manager
    - Guides through GitHub authentication
    - Tests functionality and creates quick reference

EXAMPLES:
    ./install_github_cli.sh          # Install and setup
    ./install_github_cli.sh --help   # Show this help

REQUIREMENTS:
    - macOS: Homebrew recommended
    - Linux: sudo access for package installation
    - Internet connection for download and authentication

NOTES:
    After installation, you can create GitHub issues directly from
    the command line using the create_github_issue.sh script.
HELP_EOF
    exit 0
fi

# Execute main function
main "$@"
