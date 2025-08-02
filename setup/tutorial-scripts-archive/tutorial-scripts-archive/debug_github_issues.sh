#!/bin/bash

# Debug GitHub Issue Creation - Find out why issues weren't created

set -e

echo "[$(date '+%H:%M:%S')] 🔍 Debug GitHub Issue Creation"
echo "=================================================="

# Function for logging
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log_action "🎯 Investigating GitHub issue creation failure"

# Step 1: Check if GitHub CLI is working
log_action "🔍 STEP 1: GitHub CLI Status"
if command -v gh &> /dev/null; then
    log_action "✅ GitHub CLI installed: $(gh --version | head -1)"
    
    if gh auth status &> /dev/null; then
        log_action "✅ GitHub authentication working"
        log_action "   User: $(gh api user --jq .login)"
    else
        log_action "❌ GitHub authentication failed"
        log_action "💡 Run: gh auth login"
        exit 1
    fi
else
    log_action "❌ GitHub CLI not found"
    exit 1
fi

# Step 2: Check repository access
log_action "🔍 STEP 2: Repository Access"

# Source environment
if [[ -f "../.core-audio-env" ]]; then
    source "../.core-audio-env"
elif [[ -f "/Users/miltronius/Development/CoreAudio/.core-audio-env" ]]; then
    source "/Users/miltronius/Development/CoreAudio/.core-audio-env"
fi

check_repo_access() {
    local repo_path="$1"
    local repo_name="$2"
    
    if [[ -d "$repo_path" ]]; then
        log_action "📁 Checking $repo_name at: $repo_path"
        cd "$repo_path"
        
        # Get remote URL
        if git remote get-url origin &> /dev/null; then
            local origin_url=$(git remote get-url origin)
            log_action "   Remote URL: $origin_url"
            
            # Extract owner/repo
            if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
                local owner="${BASH_REMATCH[1]}"
                local repo="${BASH_REMATCH[2]}"
                # Remove .git suffix if present - THIS WAS THE BUG!
                repo="${repo%.git}"
                log_action "   Parsed as: $owner/$repo (fixed .git suffix removal)"
                
                # Test GitHub CLI access to this repo
                log_action "   Testing GitHub CLI access..."
                if gh repo view "$owner/$repo" &> /dev/null; then
                    log_action "   ✅ GitHub CLI can access $owner/$repo"
                    
                    # Test issue creation permissions
                    log_action "   Testing issue list access..."
                    if gh issue list --repo "$owner/$repo" &> /dev/null; then
                        log_action "   ✅ Can list issues in $owner/$repo"
                        
                        # Show existing issues
                        local issue_count=$(gh issue list --repo "$owner/$repo" --json number | jq '. | length')
                        log_action "   📊 Current issues in $owner/$repo: $issue_count"
                    else
                        log_action "   ❌ Cannot list issues in $owner/$repo"
                        log_action "   💡 May not have issue creation permissions"
                    fi
                else
                    log_action "   ❌ GitHub CLI cannot access $owner/$repo"
                    log_action "   💡 Repository may be private or access denied"
                fi
            else
                log_action "   ❌ Could not parse GitHub URL"
            fi
        else
            log_action "   ❌ No git remote found"
        fi
    else
        log_action "❌ Repository not found: $repo_path"
    fi
}

if [[ -n "${CORE_AUDIO_ROOT:-}" ]]; then
    check_repo_access "$CORE_AUDIO_ROOT" "CoreAudioMastery"
fi

echo
if [[ -n "${TUTORIAL_ROOT:-}" ]]; then
    check_repo_access "$TUTORIAL_ROOT" "CoreAudioTutorial"
fi

# Step 3: Test issue creation manually
echo
log_action "🔍 STEP 3: Manual Issue Creation Test"

# Go back to tutorial-scripts directory
cd "$(dirname "${BASH_SOURCE[0]}")"

log_action "📝 Testing manual issue creation"
echo "Choose a repository to test issue creation:"
echo "1. CoreAudioMastery"
echo "2. CoreAudioTutorial"
echo "3. Skip test"
echo

read -p "Choose option (1/2/3): " test_choice

case $test_choice in
    1)
        repo_url="miltronium/CoreAudioMastery"
        ;;
    2)
        repo_url="miltronium/CoreAudioTutorial"
        ;;
    3)
        log_action "⏭️  Skipping manual test"
        repo_url=""
        ;;
    *)
        log_action "❌ Invalid choice"
        exit 1
        ;;
esac

if [[ -n "$repo_url" ]]; then
    log_action "🧪 Testing issue creation in $repo_url"
    
    # Create a simple test issue
    local test_title="Test Issue - Debug GitHub CLI Integration"
    local test_body="This is a test issue to debug GitHub CLI integration. Please close this issue after verification."
    
    log_action "📝 Creating test issue..."
    
    if test_issue_url=$(gh issue create \
        --title "$test_title" \
        --body "$test_body" \
        --label "test" \
        --repo "$repo_url" 2>&1); then
        
        log_action "✅ Test issue created successfully!"
        log_action "🔗 Test issue URL: $test_issue_url"
        
        # Extract issue number
        local issue_number=$(echo "$test_issue_url" | grep -o '[0-9]\+$')
        log_action "📋 Issue number: #$issue_number"
        
        echo
        log_action "🎯 SUCCESS! GitHub issue creation is working."
        log_action "💡 The problem may have been with the original script execution."
        log_action "🔧 You can now run create_github_issue.sh again."
        
        echo
        log_action "🗑️  Clean up test issue:"
        log_action "   gh issue close $issue_number --repo $repo_url"
        
    else
        log_action "❌ Test issue creation failed"
        log_action "📄 Error output:"
        echo "$test_issue_url" | while IFS= read -r line; do
            echo "    │ $line"
        done
        
        echo
        log_action "💡 Common solutions:"
        log_action "   1. Check repository permissions (need write access)"
        log_action "   2. Verify repository exists and is accessible"
        log_action "   3. Re-authenticate: gh auth login"
        log_action "   4. Check if issues are enabled in repository settings"
    fi
fi

# Step 4: Check for reference files
echo
log_action "🔍 STEP 4: Checking for Issue Reference Files"

if [[ -f "HELP_SYSTEM_REFERENCE.md" ]]; then
    log_action "✅ Found HELP_SYSTEM_REFERENCE.md"
    log_action "📄 Content preview:"
    head -10 "HELP_SYSTEM_REFERENCE.md" | while IFS= read -r line; do
        echo "    │ $line"
    done
else
    log_action "❌ No HELP_SYSTEM_REFERENCE.md found"
    log_action "💡 This confirms issues were not created successfully"
fi

# Final recommendations
echo
log_action "🎯 Debug Summary and Recommendations"
echo "=================================================="
log_action "📊 Next steps based on findings above:"
log_action "   1. If test issue creation worked: Re-run create_github_issue.sh"
log_action "   2. If permission errors: Check repository access rights"
log_action "   3. If authentication errors: Run gh auth login"
log_action "   4. If repository errors: Verify repository URLs and existence"
echo
log_action "🚀 Once issues are created successfully, run final_day1_commit.sh"
