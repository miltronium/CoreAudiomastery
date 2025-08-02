#!/bin/bash

# Combined Archive and Commit Script
# One-step process for archiving tutorial scripts and committing to both repositories

set -e

echo "[$(date '+%H:%M:%S')] 🚀 Archive and Commit - Tutorial Scripts"
echo "============================================================="

# Save original directory and set up logging
ORIGINAL_DIR=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="archive_commit_log_${TIMESTAMP}.log"

# Enhanced logging function
log_action() {
    local message="$1"
    echo "[$(date '+%H:%M:%S')] $message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
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
    
    # Use eval for proper command expansion
    output=$(eval "git $cmd" 2>&1) || exit_code=$?
    exit_code=${exit_code:-0}
    
    log_git_output "git $cmd" "$output" "$exit_code"
    
    # Return the exit code for decision making
    return $exit_code
}

log_action "🔧 Starting combined archive and commit process"
log_action "📁 Script directory: $SCRIPT_DIR"
log_action "📁 Original directory: $ORIGINAL_DIR"

# Function to detect environment and set up paths
detect_environment() {
    log_action "🔍 Detecting environment configuration"
    
    # Check for existing environment file
    local env_paths=(
        "$ORIGINAL_DIR/.core-audio-env"
        "$HOME/Development/CoreAudio/.core-audio-env"
        "../.core-audio-env"
        ".core-audio-env"
    )
    
    for env_file in "${env_paths[@]}"; do
        if [[ -f "$env_file" ]]; then
            log_action "📍 Found environment file: $env_file"
            source "$env_file"
            return 0
        fi
    done
    
    # Fallback: detect from directory structure
    if [[ -d "$HOME/Development/CoreAudio" ]]; then
        export CORE_AUDIO_ROOT="$HOME/Development/CoreAudio/CoreAudioMastery"
        export TUTORIAL_ROOT="$HOME/Development/CoreAudio/CoreAudioTutorial"
        export LOGS_DIR="$HOME/Development/CoreAudio/logs"
        log_action "✅ Environment detected from standard location"
        return 0
    elif [[ -d "CoreAudioMastery" && -d "CoreAudioTutorial" ]]; then
        export CORE_AUDIO_ROOT="$ORIGINAL_DIR/CoreAudioMastery"
        export TUTORIAL_ROOT="$ORIGINAL_DIR/CoreAudioTutorial"
        export LOGS_DIR="$ORIGINAL_DIR/logs"
        log_action "✅ Environment detected from current directory"
        return 0
    else
        log_action "❌ Could not detect environment. Please run setup scripts first."
        return 1
    fi
}

# Archive function (from archive_tutorial_scripts.sh)
archive_scripts() {
    local destination="$1"
    local description="$2"
    
    log_action "📦 Archiving tutorial scripts to $description"
    
    # Create archive directory structure
    mkdir -p "$destination/tutorial-scripts"
    mkdir -p "$destination/setup/scripts"
    mkdir -p "$destination/setup/logs"
    
    # Determine source directory for tutorial scripts
    local source_dir=""
    if [[ -d "tutorial-scripts" ]]; then
        source_dir="tutorial-scripts"
    elif [[ "$(basename "$ORIGINAL_DIR")" == "tutorial-scripts" ]]; then
        # We're running from within tutorial-scripts directory
        source_dir="$ORIGINAL_DIR"
    elif [[ -d "$ORIGINAL_DIR/tutorial-scripts" ]]; then
        source_dir="$ORIGINAL_DIR/tutorial-scripts"
    fi
    
    # Archive all tutorial scripts
    if [[ -n "$source_dir" && -d "$source_dir" ]]; then
        log_action "📄 Copying tutorial scripts from: $source_dir"
        # Copy all files from source directory
        find "$source_dir" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.md" -o -name "*.txt" \) -exec cp {} "$destination/tutorial-scripts/" \;
        # Count copied files
        local file_count=$(find "$destination/tutorial-scripts/" -type f | wc -l)
        log_action "📊 Copied $file_count files to tutorial-scripts archive"
    else
        log_action "⚠️  No tutorial-scripts directory found at any expected location"
        log_action "    Checked: tutorial-scripts, $ORIGINAL_DIR, $ORIGINAL_DIR/tutorial-scripts"
    fi
    
    # Archive setup scripts (if they exist)
    local setup_scripts=(
        "step00_setup_steps_generator.sh"
        "activate-ca-env.sh"
        "validate-environment.sh"
    )
    
    for script in "${setup_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            log_action "📄 Archiving setup script: $script"
            cp "$script" "$destination/setup/scripts/"
        fi
    done
    
    # Archive logs
    if [[ -d "logs" ]]; then
        log_action "📄 Archiving session logs"
        cp -r logs/* "$destination/setup/logs/" 2>/dev/null || true
    fi
    
    # Create archive README
    cat > "$destination/setup/README.md" << 'ARCHIVE_README_EOF'
# Core Audio Tutorial - Archived Setup Scripts

## Contents

### tutorial-scripts/
Complete tutorial setup scripts with progression tracking

### scripts/
Additional setup and utility scripts

### logs/
Session logs from tutorial setup process

## Usage

These scripts represent the complete tutorial workflow and are archived
for reference and potential reuse.
ARCHIVE_README_EOF

    log_action "✅ Archive complete: $description"
    return 0
}

# Copy to study guide function (from archive_tutorial_scripts.sh)
copy_to_study_guide() {
    local study_guide_root="$1"
    
    log_action "📚 Copying scripts to study guide repository"
    
    # Create study guide setup directory
    mkdir -p "$study_guide_root/setup"
    mkdir -p "$study_guide_root/setup/tutorial-scripts"
    mkdir -p "$study_guide_root/setup/session-logs"
    
    # Copy tutorial scripts (handle multiple locations)
    local source_dir=""
    if [[ -d "tutorial-scripts" ]]; then
        source_dir="tutorial-scripts"
    elif [[ "$(basename "$ORIGINAL_DIR")" == "tutorial-scripts" ]]; then
        source_dir="$ORIGINAL_DIR"
    elif [[ -d "$ORIGINAL_DIR/tutorial-scripts" ]]; then
        source_dir="$ORIGINAL_DIR/tutorial-scripts"
    fi
    
    if [[ -n "$source_dir" && -d "$source_dir" ]]; then
        find "$source_dir" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.md" -o -name "*.txt" \) -exec cp {} "$study_guide_root/setup/tutorial-scripts/" \;
        log_action "📄 Tutorial scripts copied to study guide from: $source_dir"
    else
        log_action "⚠️  No tutorial scripts found to copy to study guide"
    fi
    
    # Copy session logs if they exist
    if [[ -d "logs" ]]; then
        cp -r logs/* "$study_guide_root/setup/session-logs/" 2>/dev/null || true
        log_action "📄 Session logs copied to study guide"
    fi
    
    log_action "✅ Study guide archive complete"
    return 0
}

# Enhanced commit function (from tutorial_scripts_commit.sh)
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
    
    log_action "📊 BEFORE - Remote configuration:"
    if run_git_command "remote -v" "List remotes"; then
        log_action "✅ Remotes are configured"
    else
        log_action "ℹ️  No remotes configured"
    fi
    
    # Check for changes (with detailed output) - FIXED to include untracked files
    log_action "🔍 Checking for changes..."
    local has_unstaged_changes=false
    local has_staged_changes=false
    local has_untracked_files=false
    
    if ! run_git_command "diff --quiet" "Check for unstaged changes"; then
        has_unstaged_changes=true
        log_action "📝 Found unstaged changes"
    fi
    
    if ! run_git_command "diff --cached --quiet" "Check for staged changes"; then
        has_staged_changes=true
        log_action "📝 Found staged changes"
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
    
    # Create commit with detailed output - FIXED for proper file handling
    log_action "💾 Creating commit"
    
    # Write commit message to temporary file to handle multi-line properly
    local temp_commit_file=$(mktemp)
    echo "$commit_message" > "$temp_commit_file"
    
    # Use git commit -F with proper file path (no quotes in the command)
    if run_git_command "commit -F $temp_commit_file" "Create commit from file"; then
        log_action "✅ Commit created successfully"
        
        # Clean up temp file
        rm -f "$temp_commit_file"
        
        # Show the commit details
        log_action "📄 Commit details:"
        run_git_command "log -1 --stat" "Show latest commit"
    else
        log_action "❌ Failed to create commit"
        rm -f "$temp_commit_file"
        return 1
    fi
    
    # Check for remote again before pushing
    log_action "🔍 Checking remote configuration for push..."
    if run_git_command "remote get-url origin" "Get origin URL"; then
        log_action "✅ Remote 'origin' configured for push"
        
        # Attempt push with detailed logging
        log_action "📤 Attempting push to remote"
        if run_git_command "push origin main" "Push to origin/main"; then
            log_action "✅ Push successful"
            
            # Show status after push
            log_action "📊 AFTER PUSH - Status:"
            run_git_command "status" "Show status after push"
        else
            log_action "❌ Push failed"
            log_action "🔍 Investigating push failure..."
            
            # Try to get more information about the failure
            run_git_command "remote show origin" "Show remote details"
            
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
    log_action "🎯 Starting combined archive and commit process"
    
    # Detect environment
    if ! detect_environment; then
        log_action "❌ Environment detection failed"
        exit 1
    fi
    
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
    
    # Generate automatic commit message based on current context
    local current_date=$(date '+%Y-%m-%d')
    local script_count=$(find . -maxdepth 1 -name "*.sh" -o -name "*.md" | wc -l | xargs)
    
    COMMIT_MESSAGE="feat: Archive and commit tutorial scripts milestone - $current_date

- Archive $script_count tutorial scripts to both repositories
- Update workflow documentation and README
- Maintain automated commit and push process
- Continue tutorial progression

Automated milestone: $(date '+%Y-%m-%d %H:%M') ✅"
    
    echo
    log_action "📝 Auto-generated commit message:"
    echo "----------------------------------------"
    echo "$COMMIT_MESSAGE"
    echo "----------------------------------------"
    echo
    
    log_action "🚀 Starting automated archive and commit process"
    
    # Phase 1: Archive scripts to both repositories
    log_action "📦 PHASE 1: Archiving tutorial scripts"
    echo
    
    if ! archive_scripts "$CORE_AUDIO_ROOT" "CoreAudioMastery"; then
        log_action "❌ Failed to archive to CoreAudioMastery"
        exit 1
    fi
    
    if ! copy_to_study_guide "$CORE_AUDIO_ROOT"; then
        log_action "❌ Failed to copy to study guide"
        exit 1
    fi
    
    if ! archive_scripts "$TUTORIAL_ROOT" "CoreAudioTutorial"; then
        log_action "❌ Failed to archive to CoreAudioTutorial"
        exit 1
    fi
    
    # Phase 2: Commit and push to both repositories
    log_action "💾 PHASE 2: Committing and pushing changes"
    echo
    
    # CoreAudioMastery (Study Guide)
    log_action "=" "========================= REPOSITORY 1/2 ========================="
    if ! commit_and_push "$CORE_AUDIO_ROOT" "CoreAudioMastery" "$COMMIT_MESSAGE"; then
        log_action "❌ Failed to commit/push CoreAudioMastery"
        exit 1
    fi
    
    echo
    log_action "=" "========================= REPOSITORY 2/2 ========================="
    # CoreAudioTutorial (Tutorial)
    if ! commit_and_push "$TUTORIAL_ROOT" "CoreAudioTutorial" "$COMMIT_MESSAGE"; then
        log_action "❌ Failed to commit/push CoreAudioTutorial"
        exit 1
    fi
    
    # Final status
    echo
    echo "============================================================================="
    log_action "🎉 Combined Archive and Commit Process Complete!"
    log_action "✅ Tutorial scripts archived and committed to both repositories"
    log_action "✅ Changes pushed to GitHub successfully"
    echo
    log_action "📊 Process Summary:"
    log_action "   • Scripts archived to CoreAudioMastery and CoreAudioTutorial"
    log_action "   • Professional commit messages applied"
    log_action "   • GitHub repositories synchronized"
    log_action "   • Workflow documentation updated"
    echo
    log_action "📄 Session log: $LOG_FILE"
    log_action "🎯 Ready for next tutorial phase or conversation transition"
    echo
    
    return 0
}

# Execute main function
main "$@"
