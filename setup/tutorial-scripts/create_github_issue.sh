#!/bin/bash

# Create GitHub Issue for Help System Enhancement
# Automates the creation of GitHub issue using GitHub CLI

set -e

echo "[$(date '+%H:%M:%S')] 🚀 GitHub Issue Creator - Help System Enhancement"
echo "=================================================================="

# Function for logging
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Check if GitHub CLI is installed
check_github_cli() {
    log_action "🔍 Checking for GitHub CLI (gh)"
    
    if command -v gh &> /dev/null; then
        log_action "✅ GitHub CLI found: $(gh --version | head -1)"
        return 0
    else
        log_action "❌ GitHub CLI not found"
        log_action "💡 Installation options:"
        log_action "   macOS: brew install gh"
        log_action "   Other: https://cli.github.com/"
        return 1
    fi
}

# Check GitHub authentication
check_github_auth() {
    log_action "🔍 Checking GitHub authentication"
    
    if gh auth status &> /dev/null; then
        log_action "✅ GitHub authentication verified"
        log_action "   User: $(gh api user --jq .login)"
        return 0
    else
        log_action "❌ GitHub authentication required"
        log_action "💡 Run: gh auth login"
        return 1
    fi
}

# Detect repositories (plural - can find multiple)
detect_repositories() {
    log_action "🔍 Detecting GitHub repositories"
    
    # Array to store found repositories
    declare -a FOUND_REPOS=()
    
    # Check if we have environment variables for both repos
    if [[ -f "../.core-audio-env" ]]; then
        source "../.core-audio-env"
    elif [[ -f "/Users/miltronius/Development/CoreAudio/.core-audio-env" ]]; then
        source "/Users/miltronius/Development/CoreAudio/.core-audio-env"
    fi
    
    # Function to check a directory for GitHub repo
    check_repo_dir() {
        local dir="$1"
        local name="$2"
        
        if [[ -d "$dir/.git" ]]; then
            log_action "🔍 Checking $name: $dir"
            if (cd "$dir" && git remote get-url origin &> /dev/null); then
                local origin_url=$(cd "$dir" && git remote get-url origin)
                
                if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
                    local owner="${BASH_REMATCH[1]}"
                    local repo="${BASH_REMATCH[2]}"
                    log_action "✅ Found GitHub repo: $owner/$repo at $dir"
                    FOUND_REPOS+=("$owner/$repo|$dir|$name")
                    return 0
                fi
            fi
        fi
        return 1
    }
    
    # Check known repository locations
    if [[ -n "${CORE_AUDIO_ROOT:-}" ]]; then
        check_repo_dir "$CORE_AUDIO_ROOT" "CoreAudioMastery"
    fi
    
    if [[ -n "${TUTORIAL_ROOT:-}" ]]; then
        check_repo_dir "$TUTORIAL_ROOT" "CoreAudioTutorial"
    fi
    
    # Also search parent directories as fallback
    local search_dirs=("../" "../../" "../../../")
    for dir in "${search_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            # Check if directory looks like our repos
            local basename=$(basename "$(cd "$dir" && pwd)")
            if [[ "$basename" == "CoreAudioMastery" || "$basename" == "CoreAudioTutorial" ]]; then
                check_repo_dir "$dir" "$basename"
            fi
        fi
    done
    
    # Show results
    if [[ ${#FOUND_REPOS[@]} -eq 0 ]]; then
        log_action "❌ No GitHub repositories found"
        log_action "💡 Make sure CoreAudioMastery and/or CoreAudioTutorial repos exist"
        return 1
    else
        log_action "📊 Found ${#FOUND_REPOS[@]} GitHub repository(ies):"
        for repo_info in "${FOUND_REPOS[@]}"; do
            IFS='|' read -r repo_name repo_path repo_display <<< "$repo_info"
            log_action "   • $repo_display: $repo_name"
        done
        return 0
    fi
}

# Create the issue
create_github_issue() {
    log_action "📝 Creating GitHub issue for help system enhancement"
    
    # Change to git root directory if needed
    local original_dir="$(pwd)"
    if [[ -n "${GIT_ROOT_DIR:-}" ]]; then
        log_action "📂 Changing to git root directory: $GIT_ROOT_DIR"
        cd "$GIT_ROOT_DIR"
    fi
    
    # Define issue content
    local title="Add standardized help system to all tutorial scripts"
    local body_file=$(mktemp)
    
    # Write issue body to temp file - FIXED heredoc
    cat > "$body_file" << 'ISSUE_BODY_EOF'
## 📋 Overview
Add consistent `--help` and `-h` flag support to all executable scripts in the tutorial system for improved usability and professional standards.

## 🎯 Requirements
- [ ] All `.sh` scripts support `--help` or `-h` flag
- [ ] Consistent help format across all executables
- [ ] Usage examples and argument descriptions
- [ ] Integration without breaking existing functionality

## 🛠️ Implementation Details

### Standard Help Template
```bash
show_help() {
    cat << 'HELP_EOF'
SCRIPT_NAME - Brief description

USAGE:
    ./script_name.sh [OPTIONS] [ARGUMENTS]

OPTIONS:
    -h, --help              Show this help message

EXAMPLES:
    ./script_name.sh --help

DESCRIPTION:
    Detailed description of what the script does...
HELP_EOF
}

case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
esac
```

## 📝 Scripts to Update

### Phase 1: Core Workflow Scripts
- [ ] `archive_and_commit.sh` - Combined workflow help
- [ ] `archive_tutorial_scripts.sh` - Archive options help
- [ ] `tutorial_scripts_commit.sh` - Commit process help

### Phase 2: Setup Scripts
- [ ] `step01_create_directories.sh` - Directory setup help
- [ ] `step02_initialize_repos.sh` - Git initialization help
- [ ] `step03_setup_environment.sh` - Environment setup help
- [ ] `step04_install_frameworks.sh` - Framework installation help

### Phase 3: Future Scripts
- [ ] All new scripts include help from creation
- [ ] Update script templates with help system

## ⏰ Timeline
- **Priority**: Medium-High (Quality of life improvement)
- **Timing**: After Day 2 Foundation Building completion
- **Estimated Time**: 2-3 hours for all existing scripts
- **Target Completion**: Day 17 (Final Validation phase)

## ✅ Success Criteria
- [ ] All executable scripts respond to `--help` flag
- [ ] Help output is consistent and informative
- [ ] Usage examples are accurate and helpful
- [ ] No existing functionality is broken
- [ ] Help system documented in WORKFLOW_README.md

## 🔗 Benefits
- **Improved usability** - Self-documenting scripts
- **Professional standard** - Industry best practice
- **Learning aid** - Built-in reference for complex scripts
- **Debugging support** - Clear usage when scripts fail
- **Onboarding** - New users can understand scripts quickly

## 📖 Implementation Notes
- Help text should match WORKFLOW_README.md documentation
- Examples should reflect actual usage patterns
- Keep help concise but comprehensive
- Test help functionality doesn't break existing workflows
ISSUE_BODY_EOF
    
    # Create the issue using GitHub CLI
    log_action "🚀 Creating issue with GitHub CLI"
    
    local issue_url
    issue_url=$(gh issue create \
        --title "$title" \
        --body-file "$body_file" \
        --label "enhancement,documentation,user-experience" \
        --repo "$REPO_OWNER/$REPO_NAME")
    
    # Clean up temp file
    rm -f "$body_file"
    
    # Return to original directory
    if [[ -n "${GIT_ROOT_DIR:-}" ]]; then
        cd "$original_dir"
        log_action "📂 Returned to original directory: $original_dir"
    fi
    
    if [[ -n "$issue_url" ]]; then
        log_action "✅ Issue created successfully!"
        log_action "🔗 Issue URL: $issue_url"
        
        # Extract issue number from URL
        local issue_number
        issue_number=$(echo "$issue_url" | grep -o '[0-9]\+$')
        
        # Create local reference file
        create_reference_file "$issue_number" "$issue_url"
        
        return 0
    else
        log_action "❌ Failed to create issue"
        return 1
    fi
}

# Create local reference file
create_reference_file() {
    local issue_number="$1"
    local issue_url="$2"
    
    log_action "📄 Creating local reference file"
    
    cat > "HELP_SYSTEM_REFERENCE.md" << REF_EOF
# Help System Enhancement - GitHub Issue Reference

## Issue Details
- **Issue Number**: #$issue_number
- **Issue URL**: $issue_url
- **Repository**: $REPO_OWNER/$REPO_NAME
- **Created**: $(date '+%Y-%m-%d %H:%M:%S')

## Quick Commands
\`\`\`bash
# View issue
gh issue view $issue_number

# Add comment
gh issue comment $issue_number --body "Your comment"

# Close issue when complete
gh issue close $issue_number
\`\`\`

## Status
- **Priority**: Medium-High
- **Target**: Day 17 (Final Validation phase)
- **Estimated**: 2-3 hours total

## Implementation Tracking
Use the GitHub issue to track progress on adding help systems to all tutorial scripts.
REF_EOF

    log_action "✅ Reference file created: HELP_SYSTEM_REFERENCE.md"
}

# Main execution
main() {
    log_action "🎯 Starting GitHub issue creation process"
    
    # Check prerequisites
    if ! check_github_cli; then
        log_action "❌ GitHub CLI not available"
        exit 1
    fi
    
    if ! check_github_auth; then
        log_action "❌ GitHub authentication required"
        log_action "💡 Run: gh auth login"
        exit 1
    fi
    
    if ! detect_repositories; then
        log_action "❌ Could not detect GitHub repositories"
        exit 1
    fi
    
    # Let user choose which repository(ies) to create issues in
    echo
    log_action "📋 Choose repository for issue creation:"
    echo "1. CoreAudioMastery only"
    echo "2. CoreAudioTutorial only"  
    echo "3. Both repositories (recommended)"
    echo "4. Exit"
    echo
    
    read -p "Choose option (1/2/3/4): " choice
    
    case $choice in
        1)
            # Find CoreAudioMastery repo
            for repo_info in "${FOUND_REPOS[@]}"; do
                IFS='|' read -r repo_name repo_path repo_display <<< "$repo_info"
                if [[ "$repo_display" == "CoreAudioMastery" ]]; then
                    REPO_OWNER="${repo_name%%/*}"
                    REPO_NAME="${repo_name##*/}"
                    GIT_ROOT_DIR="$repo_path"
                    log_action "🎯 Creating issue in CoreAudioMastery only"
                    if create_github_issue; then
                        log_action "✅ Issue created in CoreAudioMastery"
                    fi
                    return 0
                fi
            done
            log_action "❌ CoreAudioMastery repository not found"
            exit 1
            ;;
        2)
            # Find CoreAudioTutorial repo
            for repo_info in "${FOUND_REPOS[@]}"; do
                IFS='|' read -r repo_name repo_path repo_display <<< "$repo_info"
                if [[ "$repo_display" == "CoreAudioTutorial" ]]; then
                    REPO_OWNER="${repo_name%%/*}"
                    REPO_NAME="${repo_name##*/}"
                    GIT_ROOT_DIR="$repo_path"
                    log_action "🎯 Creating issue in CoreAudioTutorial only"
                    if create_github_issue; then
                        log_action "✅ Issue created in CoreAudioTutorial"
                    fi
                    return 0
                fi
            done
            log_action "❌ CoreAudioTutorial repository not found"
            exit 1
            ;;
        3)
            # Create in both repositories
            log_action "🎯 Creating issues in both repositories"
            local success_count=0
            
            for repo_info in "${FOUND_REPOS[@]}"; do
                IFS='|' read -r repo_name repo_path repo_display <<< "$repo_info"
                REPO_OWNER="${repo_name%%/*}"
                REPO_NAME="${repo_name##*/}"
                GIT_ROOT_DIR="$repo_path"
                
                echo
                log_action "📦 Creating issue in $repo_display ($repo_name)"
                if create_github_issue; then
                    log_action "✅ Issue created successfully in $repo_display"
                    ((success_count++))
                else
                    log_action "❌ Failed to create issue in $repo_display"
                fi
            done
            
            if [[ $success_count -eq ${#FOUND_REPOS[@]} ]]; then
                log_action "🎉 Issues created successfully in all repositories!"
            elif [[ $success_count -gt 0 ]]; then
                log_action "⚠️  Issues created in $success_count of ${#FOUND_REPOS[@]} repositories"
            else
                log_action "❌ Failed to create issues in any repository"
                exit 1
            fi
            ;;
        4)
            log_action "👋 Issue creation cancelled by user"
            exit 0
            ;;
        *)
            log_action "❌ Invalid option: $choice"
            exit 1
            ;;
    esac
    
    echo
    log_action "🎉 GitHub Issue Creation Complete!"
    log_action "✅ Help system enhancement is now tracked professionally"
    log_action "📁 Local reference: HELP_SYSTEM_REFERENCE.md"
    echo
    log_action "🎯 Next: Continue with Day 2 tutorial implementation"
    log_action "🔗 View issues: gh issue list"
}

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'HELP_EOF'
create_github_issue.sh - Create GitHub issue for help system enhancement

USAGE:
    ./create_github_issue.sh

DESCRIPTION:
    Automatically creates a GitHub issue to track the addition of help systems
    to all tutorial scripts. Supports both CoreAudioMastery and CoreAudioTutorial
    repositories with option to create issues in one or both.

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Git repository with GitHub remote
    - Write access to the repository

EXAMPLES:
    ./create_github_issue.sh          # Create the issue
    ./create_github_issue.sh --help   # Show this help

NOTES:
    The script will detect both repositories and allow you to choose
    which one(s) to create issues in. Option 3 (both repositories) is recommended.
HELP_EOF
    exit 0
fi

# Execute main function
main "$@"
