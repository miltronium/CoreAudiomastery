#!/bin/bash

# Fixed GitHub Issue Creator - Help System Enhancement
# Fixes the substring expression error

set -e

echo "[$(date '+%H:%M:%S')] 🚀 GitHub Issue Creator - Help System Enhancement"
echo "=================================================================="

# Function to log with timestamp
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Check for GitHub CLI
log_action "🎯 Starting GitHub issue creation process"
log_action "🔍 Checking for GitHub CLI (gh)"

if ! command -v gh &> /dev/null; then
    log_action "❌ GitHub CLI not found. Please install it first:"
    echo "   brew install gh"
    echo "   or visit: https://cli.github.com/"
    exit 1
fi

GH_VERSION=$(gh --version | head -n1)
log_action "✅ GitHub CLI found: $GH_VERSION"

# Check authentication
log_action "🔍 Checking GitHub authentication"
if ! gh auth status &> /dev/null; then
    log_action "❌ Not authenticated with GitHub. Please run:"
    echo "   gh auth login"
    exit 1
fi

USER_INFO=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
log_action "✅ GitHub authentication verified"
log_action "   User: $USER_INFO"

# Detect repositories
log_action "🔍 Detecting GitHub repositories"

# Function to safely check for remote and extract repo name
get_repo_info() {
    local dir="$1"
    local repo_name=""
    local has_remote=false
    
    if [[ -d "$dir/.git" ]]; then
        cd "$dir"
        if git remote get-url origin &> /dev/null; then
            local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
            if [[ -n "$remote_url" ]]; then
                # Extract repo name from various URL formats
                if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
                    repo_name="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
                    has_remote=true
                elif [[ "$remote_url" =~ ([^/]+)/([^/]+)(\.git)?$ ]]; then
                    repo_name="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
                    has_remote=true
                fi
                # Remove .git suffix if present
                repo_name="${repo_name%.git}"
            fi
        fi
    fi
    
    echo "$has_remote:$repo_name"
}

# Check CoreAudioMastery
MASTERY_DIR="/Users/miltronius/Development/CoreAudio/CoreAudioMastery"
if [[ -d "$MASTERY_DIR" ]]; then
    log_action "🔍 Checking CoreAudioMastery: $MASTERY_DIR"
    MASTERY_INFO=$(get_repo_info "$MASTERY_DIR")
    MASTERY_HAS_REMOTE="${MASTERY_INFO%%:*}"
    MASTERY_REPO="${MASTERY_INFO##*:}"
    
    if [[ "$MASTERY_HAS_REMOTE" == "true" && -n "$MASTERY_REPO" ]]; then
        log_action "✅ Found CoreAudioMastery repository: $MASTERY_REPO"
        SELECTED_REPO="$MASTERY_REPO"
        SELECTED_DIR="$MASTERY_DIR"
    else
        log_action "⚠️  CoreAudioMastery exists but no GitHub remote found"
    fi
else
    log_action "⚠️  CoreAudioMastery directory not found"
fi

# Check CoreAudioTutorial
TUTORIAL_DIR="/Users/miltronius/Development/CoreAudio/CoreAudioTutorial"
if [[ -d "$TUTORIAL_DIR" ]]; then
    log_action "🔍 Checking CoreAudioTutorial: $TUTORIAL_DIR"
    TUTORIAL_INFO=$(get_repo_info "$TUTORIAL_DIR")
    TUTORIAL_HAS_REMOTE="${TUTORIAL_INFO%%:*}"
    TUTORIAL_REPO="${TUTORIAL_INFO##*:}"
    
    if [[ "$TUTORIAL_HAS_REMOTE" == "true" && -n "$TUTORIAL_REPO" ]]; then
        log_action "✅ Found CoreAudioTutorial repository: $TUTORIAL_REPO"
        if [[ -z "$SELECTED_REPO" ]]; then
            SELECTED_REPO="$TUTORIAL_REPO"
            SELECTED_DIR="$TUTORIAL_DIR"
        fi
    else
        log_action "⚠️  CoreAudioTutorial exists but no GitHub remote found"
    fi
else
    log_action "⚠️  CoreAudioTutorial directory not found"
fi

# Repository selection
if [[ -z "$SELECTED_REPO" ]]; then
    log_action "❌ No GitHub repositories found with remotes"
    log_action "💡 Please ensure you have GitHub repositories set up with remotes"
    echo
    echo "To set up a repository:"
    echo "1. Create a repository on GitHub"
    echo "2. cd to your local repository directory"
    echo "3. git remote add origin https://github.com/username/repo-name.git"
    echo "4. git push -u origin main"
    exit 1
fi

if [[ -n "$MASTERY_REPO" && -n "$TUTORIAL_REPO" ]]; then
    echo
    log_action "📋 Multiple repositories found:"
    echo "   1. CoreAudioMastery: $MASTERY_REPO"
    echo "   2. CoreAudioTutorial: $TUTORIAL_REPO"
    echo
    read -p "Select repository (1 or 2, or press Enter for CoreAudioMastery): " choice
    
    case "$choice" in
        "2")
            SELECTED_REPO="$TUTORIAL_REPO"
            SELECTED_DIR="$TUTORIAL_DIR"
            ;;
        *)
            SELECTED_REPO="$MASTERY_REPO"
            SELECTED_DIR="$MASTERY_DIR"
            ;;
    esac
fi

log_action "🎯 Selected repository: $SELECTED_REPO"

# Create the GitHub issue
ISSUE_TITLE="Tutorial Help System Enhancement Request"

ISSUE_BODY="## Tutorial Progress Support Request

### Current Status
- **Repository**: $SELECTED_REPO
- **Local Path**: $SELECTED_DIR
- **User**: $USER_INFO
- **Request Time**: $(date '+%Y-%m-%d %H:%M:%S')

### Request Type
This is a tutorial progression assistance request for the Core Audio Mastery study guide implementation.

### Context
I'm following the comprehensive Core Audio tutorial and need assistance with the next steps in my learning progression.

### Environment Information
- **GitHub CLI**: $GH_VERSION
- **Repository Status**: Active development
- **Authentication**: Verified

### Expected Response
Please provide detailed guidance for continuing the tutorial progression, including:
- Specific next steps
- Code implementations
- Testing procedures
- Commit strategies

### Labels
- tutorial-help
- core-audio
- learning-progression

---
*This issue was created automatically by the tutorial help system.*"

# Create the issue
log_action "📝 Creating GitHub issue..."

cd "$SELECTED_DIR"

# First, try to create the issue without labels (in case labels don't exist)
if gh issue create \
    --title "$ISSUE_TITLE" \
    --body "$ISSUE_BODY"; then
    
    log_action "✅ GitHub issue created successfully!"
    
    # Get the issue number and URL
    ISSUE_NUMBER=$(gh issue list --limit 1 --json number --jq '.[0].number' 2>/dev/null || echo "")
    ISSUE_URL=$(gh issue list --limit 1 --json url --jq '.[0].url' 2>/dev/null || echo "")
    
    # Try to add labels if issue was created
    if [[ -n "$ISSUE_NUMBER" ]]; then
        log_action "🏷️  Attempting to add labels..."
        
        # Try each label individually to see which ones exist
        for label in "tutorial-help" "core-audio" "learning-progression"; do
            if gh issue edit "$ISSUE_NUMBER" --add-label "$label" 2>/dev/null; then
                log_action "✅ Added label: $label"
            else
                log_action "⚠️  Label '$label' doesn't exist (you can create it manually on GitHub)"
            fi
        done
    fi
    
    if [[ -n "$ISSUE_URL" ]]; then
        log_action "🔗 Issue URL: $ISSUE_URL"
    fi
    
    echo
    log_action "🎉 Tutorial help request submitted!"
    log_action "📋 Check your GitHub repository for the issue and responses"
    
    # Provide helpful next steps
    echo
    log_action "💡 Next steps:"
    echo "   1. Visit the issue URL above to view the request"
    echo "   2. You can manually add labels in the GitHub web interface"
    echo "   3. The tutorial author will respond with guidance"
    
else
    log_action "❌ Failed to create GitHub issue"
    log_action "💡 This might be due to repository permissions or network issues"
    
    # Provide troubleshooting suggestions
    echo
    log_action "🔧 Troubleshooting suggestions:"
    echo "   1. Check that you have write access to the repository"
    echo "   2. Verify your GitHub authentication: gh auth status"
    echo "   3. Try refreshing your auth token: gh auth refresh"
    echo "   4. Check if issues are enabled for this repository"
    
    exit 1
fi

echo
log_action "✨ Help system activation complete!"
