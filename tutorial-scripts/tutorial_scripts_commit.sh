#!/bin/bash

# Tutorial Scripts Commit and Push - Enhanced with Git Logging
# Commits the completed tutorial scripts setup to both repositories
# Now with comprehensive git status and response logging

set -e

echo "[$(date '+%H:%M:%S')] 🚀 Tutorial Scripts - Commit and Push (Enhanced Logging)"
echo "============================================================================="

# Function for logging
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Function to log git command output
log_git_output() {
    local command="$1"
    local output="$2"
    local exit_code="$3"
    
    log_action "🔧 Git Command: $command"
    if [[ -n "$output" ]]; then
        echo "$output" | while IFS= read -r line; do
            echo "    │ $line"
        done
    else
        echo "    │ (no output)"
    fi
    log_action "📊 Exit Code: $exit_code"
}

# Enhanced git command wrapper
run_git_command() {
    local cmd="$1"
    local description="$2"
    
    log_action "🔧 Running: $description"
    echo "    Command: git $cmd"
    
    # Capture both output and exit code
    local output
    local exit_code
    
    output=$(git $cmd 2>&1) || exit_code=$?
    exit_code=${exit_code:-0}
    
    log_git_output "git $cmd" "$output" "$exit_code"
    
    # Return the exit code for decision making
    return $exit_code
}

# Source environment
if [[ -f "/Users/miltronius/Development/CoreAudio/.core-audio-env" ]]; then
    source "/Users/miltronius/Development/CoreAudio/.core-audio-env"
    log_action "✅ Environment loaded"
    log_action "   CORE_AUDIO_ROOT: $CORE_AUDIO_ROOT"
    log_action "   TUTORIAL_ROOT: $TUTORIAL_ROOT"
else
    log_action "❌ Environment file not found"
    exit 1
fi

# Function to commit and push repository with enhanced logging
commit_and_push() {
    local repo_path="$1"
    local repo_name="$2"
    local commit_message="$3"
    
    log_action "📦 Processing $repo_name repository"
    log_action "📁 Repository path: $repo_path"
    
    if [[ ! -d "$repo_path" ]]; then
        log_action "❌ Repository not found: $repo_path"
        return 1
    fi
    
    cd "$repo_path"
    log_action "📂 Changed to directory: $(pwd)"
    
    # Check if it's a git repository
    if [[ ! -d ".git" ]]; then
        log_action "🔧 Initializing git repository in $repo_name"
        run_git_command "init" "Initialize repository"
        run_git_command "branch -M main" "Set main branch"
    else
        log_action "✅ Git repository already exists"
    fi
    
    # Show detailed git status BEFORE any changes
    log_action "📊 BEFORE - Git status for $repo_name:"
    run_git_command "status" "Check repository status"
    
    log_action "📊 BEFORE - Git branch info:"
    run_git_command "branch -v" "Show branch information"
    
    # Check for remotes with detailed output
    log_action "📊 BEFORE - Remote configuration:"
    if run_git_command "remote -v" "List remotes"; then
        log_action "✅ Remotes are configured"
    else
        log_action "ℹ️  No remotes configured"
    fi
    
    # Show what files would be added
    log_action "📊 Files to be added:"
    run_git_command "status --porcelain" "Show files to be staged"
    
    # Check for changes (with detailed output) - FIXED to include untracked files
    log_action "🔍 Checking for changes..."
    local has_unstaged_changes=false
    local has_staged_changes=false
    local has_untracked_files=false
    
    if ! run_git_command "diff --quiet" "Check for unstaged changes"; then
        has_unstaged_changes=true
        log_action "📝 Found unstaged changes"
        log_action "📄 Unstaged changes summary:"
        run_git_command "diff --stat" "Show unstaged changes summary"
    fi
    
    if ! run_git_command "diff --cached --quiet" "Check for staged changes"; then
        has_staged_changes=true
        log_action "📝 Found staged changes"
        log_action "📄 Staged changes summary:"
        run_git_command "diff --cached --stat" "Show staged changes summary"
    fi
    
    # FIXED: Check for untracked files using git status --porcelain
    local status_output
    status_output=$(git status --porcelain 2>/dev/null || echo "")
    if [[ -n "$status_output" ]]; then
        has_untracked_files=true
        log_action "📝 Found untracked/modified files"
        log_action "📄 All changes (including untracked):"
        echo "$status_output" | while IFS= read -r line; do
            echo "    │ $line"
        done
    fi
    
    if [[ "$has_unstaged_changes" == false && "$has_staged_changes" == false && "$has_untracked_files" == false ]]; then
        log_action "ℹ️  No changes to commit in $repo_name"
        return 0
    fi
    
    # Add all changes with detailed output
    log_action "➕ Adding changes to staging"
    run_git_command "add ." "Stage all changes"
    
    # Show what was staged
    log_action "📊 AFTER STAGING - What's staged:"
    run_git_command "diff --cached --stat" "Show staged changes"
    run_git_command "status --porcelain" "Show staging status"
    
    # Create commit with detailed output
    log_action "💾 Creating commit"
    if run_git_command "commit -m \"$commit_message\"" "Create commit"; then
        log_action "✅ Commit created successfully"
        
        # Show the commit details
        log_action "📄 Commit details:"
        run_git_command "log -1 --stat" "Show latest commit"
    else
        log_action "❌ Failed to create commit"
        return 1
    fi
    
    # Check for remote again before pushing
    log_action "🔍 Checking remote configuration for push..."
    if run_git_command "remote get-url origin" "Get origin URL"; then
        log_action "✅ Remote 'origin' configured for push"
        
        # Show current branch before push
        log_action "📊 BEFORE PUSH - Current branch:"
        run_git_command "branch -v" "Show branch before push"
        
        # Attempt push with detailed logging
        log_action "📤 Attempting push to remote"
        if run_git_command "push origin main" "Push to origin/main"; then
            log_action "✅ Push successful"
            
            # Show status after push
            log_action "📊 AFTER PUSH - Status:"
            run_git_command "status" "Show status after push"
            run_git_command "log -1 --oneline" "Show latest commit"
        else
            log_action "❌ Push failed"
            log_action "🔍 Investigating push failure..."
            
            # Try to get more information about the failure
            run_git_command "remote show origin" "Show remote details"
            run_git_command "branch -vv" "Show tracking branches"
            
            log_action "💡 Possible solutions:"
            log_action "   1. Check if remote repository exists"
            log_action "   2. Verify authentication (GitHub token/SSH)"
            log_action "   3. Check branch protection rules"
            log_action "   4. Manual push: cd $repo_path && git push origin main"
        fi
    else
        log_action "ℹ️  No remote 'origin' configured - commit created locally only"
        log_action "💡 To add remote later:"
        log_action "   cd $repo_path"
        log_action "   git remote add origin <your-repo-url>"
        log_action "   git push -u origin main"
    fi
    
    log_action "✅ $repo_name repository processing complete"
    return 0
}

# Main execution
main() {
    log_action "🎯 Starting tutorial scripts commit process with enhanced logging"
    
    # Validate environment variables
    if [[ -z "$CORE_AUDIO_ROOT" || -z "$TUTORIAL_ROOT" ]]; then
        log_action "❌ Environment variables not set"
        exit 1
    fi
    
    log_action "📁 Repositories to process:"
    log_action "   CoreAudioMastery: $CORE_AUDIO_ROOT"
    log_action "   CoreAudioTutorial: $TUTORIAL_ROOT"
    
    # Verify repositories exist
    for repo in "$CORE_AUDIO_ROOT" "$TUTORIAL_ROOT"; do
        if [[ -d "$repo" ]]; then
            log_action "✅ Repository exists: $repo"
        else
            log_action "❌ Repository not found: $repo"
            exit 1
        fi
    done
    
    # Commit message for this milestone
    COMMIT_MESSAGE="feat: Complete Day 1 setup and tutorial scripts archive

- Archive 16 tutorial setup scripts to both repositories
- Add comprehensive tutorial outline (CoreAudio_Mastery_Tutorial_Outline.md)
- Complete environment setup and validation
- Establish session logging and tracking
- Ready for Day 2: Foundation Building

Day 1 Milestone: Setup and Foundation ✅"
    
    echo
    log_action "📝 Commit message preview:"
    echo "----------------------------------------"
    echo "$COMMIT_MESSAGE"
    echo "----------------------------------------"
    echo
    
    read -p "Proceed with commit and push? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_action "👋 Commit cancelled by user"
        exit 0
    fi
    
    # Process both repositories with detailed logging
    log_action "🚀 Processing repositories with enhanced git logging"
    echo
    
    # CoreAudioMastery (Study Guide)
    log_action "=" "========================= REPOSITORY 1/2 ========================="
    if ! commit_and_push "$CORE_AUDIO_ROOT" "CoreAudioMastery" "$COMMIT_MESSAGE"; then
        log_action "❌ Failed to process CoreAudioMastery"
        exit 1
    fi
    
    echo
    log_action "=" "========================= REPOSITORY 2/2 ========================="
    # CoreAudioTutorial (Tutorial)
    if ! commit_and_push "$TUTORIAL_ROOT" "CoreAudioTutorial" "$COMMIT_MESSAGE"; then
        log_action "❌ Failed to process CoreAudioTutorial"
        exit 1
    fi
    
    # Final status
    echo
    echo "============================================================================="
    log_action "🎉 Tutorial Scripts Commit Process Complete!"
    log_action "✅ Day 1: Setup and Foundation - COMPLETE"
    log_action "🚀 Ready for Day 2: Foundation Building"
    echo
    log_action "📊 Process Summary:"
    log_action "   • 16 tutorial scripts archived and committed"
    log_action "   • Environment setup validated"
    log_action "   • Git repositories processed with detailed logging"
    log_action "   • Session tracking active"
    echo
    log_action "🔍 If push failed, check the detailed git logs above"
    log_action "🎯 Next: Begin Conversation 2 for Day 2 implementation"
    echo
}

# Execute main function
main "$@"
