#!/bin/bash

# Day 1 Commit and Push - Save Day 1 Foundation Work
# Core Audio Tutorial - Commit Day 1 setup before proceeding to Day 2

set -e

echo "======================================================================="
echo "[$(date '+%H:%M:%S')] 📦 CORE AUDIO TUTORIAL - DAY 1 COMMIT & PUSH"
echo "======================================================================="
echo

# Source environment with comprehensive detection
source_environment() {
    local env_paths=(
        "../.core-audio-env"
        "./.core-audio-env"
        "$HOME/Development/CoreAudio/.core-audio-env"
        "../../.core-audio-env"
    )
    
    for env_file in "${env_paths[@]}"; do
        if [[ -f "$env_file" ]]; then
            echo "[$(date '+%H:%M:%S')] 📍 Sourcing environment: $env_file"
            source "$env_file"
            return 0
        fi
    done
    
    echo "[$(date '+%H:%M:%S')] ❌ Environment file not found"
    return 1
}

# Enhanced logging function
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    if [[ -n "$LOGS_DIR" && -d "$LOGS_DIR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-COMMIT] $1" >> "$LOGS_DIR/day01_session.log"
    fi
}

# Git status check function
check_git_status() {
    local repo_path="$1"
    local repo_name="$2"
    
    if [[ ! -d "$repo_path" ]]; then
        log_action "❌ Repository not found: $repo_name ($repo_path)"
        return 1
    fi
    
    cd "$repo_path"
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_action "❌ Not a git repository: $repo_name"
        return 1
    fi
    
    # Check if there are any changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        if git log --oneline > /dev/null 2>&1; then
            log_action "ℹ️  No changes to commit in $repo_name"
            return 2  # No changes, but repo exists
        else
            log_action "⚠️  $repo_name has no commits yet, will create initial commit"
            return 0  # Needs initial commit
        fi
    else
        log_action "📝 Changes detected in $repo_name, ready to commit"
        return 0  # Has changes to commit
    fi
}

# Commit function with detailed staging
commit_repository() {
    local repo_path="$1"
    local repo_name="$2"
    local commit_message="$3"
    
    log_action "📦 Committing $repo_name repository"
    
    cd "$repo_path"
    
    # Show current status
    log_action "📊 Git status for $repo_name:"
    git status --porcelain | head -10 | while read line; do
        echo "    $line"
    done
    
    # Add all Day 1 related files
    git add .
    
    # Show what's being committed
    log_action "📝 Files being committed in $repo_name:"
    git diff --cached --name-only | head -10 | while read file; do
        echo "    + $file"
    done
    
    # Create commit
    if git commit -m "$commit_message"; then
        log_action "✅ Successfully committed $repo_name"
        
        # Show commit info
        COMMIT_HASH=$(git rev-parse --short HEAD)
        log_action "📌 Commit: $COMMIT_HASH - $commit_message"
        
        return 0
    else
        log_action "❌ Failed to commit $repo_name"
        return 1
    fi
}

# Source environment
source_environment || {
    log_action "❌ Cannot proceed without environment configuration"
    exit 1
}

log_action "🎯 Starting Day 1 commit and push process"

# Validate environment
if [[ -z "$CORE_AUDIO_ROOT" || -z "$TUTORIAL_ROOT" || -z "$LOGS_DIR" ]]; then
    log_action "❌ Environment variables not properly set"
    log_action "   CORE_AUDIO_ROOT: ${CORE_AUDIO_ROOT:-'not set'}"
    log_action "   TUTORIAL_ROOT: ${TUTORIAL_ROOT:-'not set'}"
    log_action "   LOGS_DIR: ${LOGS_DIR:-'not set'}"
    exit 1
fi

log_action "✅ Environment validation passed"
echo

# =====================================================================
# 1. CHECK REPOSITORY STATUS
# =====================================================================

log_action "🔍 Phase 1: Checking repository status"
echo

CORE_AUDIO_STATUS=1
TUTORIAL_STATUS=1

# Check CoreAudioMastery repository
log_action "📊 Checking CoreAudioMastery repository status..."
check_git_status "$CORE_AUDIO_ROOT" "CoreAudioMastery"
CORE_AUDIO_STATUS=$?

echo

# Check CoreAudioTutorial repository
log_action "📊 Checking CoreAudioTutorial repository status..."
check_git_status "$TUTORIAL_ROOT" "CoreAudioTutorial"
TUTORIAL_STATUS=$?

echo

# =====================================================================
# 2. PREPARE COMMIT MESSAGES
# =====================================================================

log_action "📝 Phase 2: Preparing commit messages"
echo

# Get current timestamp for commit messages
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Core Audio Mastery commit message
CORE_AUDIO_COMMIT_MSG="Day 1: Initial Core Audio Mastery setup

- Created repository structure (Chapters/, Shared/, Integration/)
- Initialized directory framework for study guide implementation
- Set up foundation for multi-language Core Audio development
- Prepared for Chapter 1 implementation

Completed: $TIMESTAMP"

# Tutorial repository commit message
TUTORIAL_COMMIT_MSG="Day 1: Core Audio Tutorial foundation setup

- Complete environment configuration and validation
- Testing frameworks installed (Unity, GoogleTest)
- Build system configured (C, Swift, CMake)
- Session logging and daily progression tracking
- Environment activation scripts
- Day 1 readiness validation passed

Completed: $TIMESTAMP"

# =====================================================================
# 3. COMMIT REPOSITORIES
# =====================================================================

log_action "📦 Phase 3: Committing repositories"
echo

COMMIT_SUCCESS=true

# Commit CoreAudioMastery if needed
if [[ $CORE_AUDIO_STATUS -eq 0 ]]; then
    if ! commit_repository "$CORE_AUDIO_ROOT" "CoreAudioMastery" "$CORE_AUDIO_COMMIT_MSG"; then
        COMMIT_SUCCESS=false
    fi
elif [[ $CORE_AUDIO_STATUS -eq 2 ]]; then
    log_action "ℹ️  CoreAudioMastery already up to date"
else
    log_action "❌ CoreAudioMastery repository issues detected"
    COMMIT_SUCCESS=false
fi

echo

# Commit CoreAudioTutorial if needed
if [[ $TUTORIAL_STATUS -eq 0 ]]; then
    if ! commit_repository "$TUTORIAL_ROOT" "CoreAudioTutorial" "$TUTORIAL_COMMIT_MSG"; then
        COMMIT_SUCCESS=false
    fi
elif [[ $TUTORIAL_STATUS -eq 2 ]]; then
    log_action "ℹ️  CoreAudioTutorial already up to date"
else
    log_action "❌ CoreAudioTutorial repository issues detected"
    COMMIT_SUCCESS=false
fi

echo

# =====================================================================
# 4. PUSH TO REMOTE (OPTIONAL)
# =====================================================================

log_action "🚀 Phase 4: Remote push options"
echo

if [[ "$COMMIT_SUCCESS" == true ]]; then
    log_action "✅ All local commits successful"
    
    # Check if user wants to push to remote
    log_action "🤔 Would you like to push to remote repositories?"
    log_action "   This is optional - you can push manually later if preferred"
    log_action "   Remote push allows backup and sharing of your progress"
    
    # For automated script, we'll skip interactive push
    # User can manually push when ready
    log_action "ℹ️  Skipping automatic remote push"
    log_action "📝 To push manually when ready:"
    log_action "   cd $CORE_AUDIO_ROOT && git push origin main"
    log_action "   cd $TUTORIAL_ROOT && git push origin main"
else
    log_action "❌ Commit issues detected - skipping remote push"
fi

echo

# =====================================================================
# 5. FINAL STATUS AND NEXT STEPS
# =====================================================================

log_action "📊 Phase 5: Final status and next steps"
echo

# Show final repository status
log_action "📈 Final repository status:"

cd "$CORE_AUDIO_ROOT"
if git log --oneline > /dev/null 2>&1; then
    CORE_COMMITS=$(git rev-list --count HEAD)
    LAST_COMMIT=$(git log -1 --format="%h - %s")
    log_action "   CoreAudioMastery: $CORE_COMMITS commit(s)"
    log_action "   Latest: $LAST_COMMIT"
else
    log_action "   CoreAudioMastery: No commits"
fi

cd "$TUTORIAL_ROOT"
if git log --oneline > /dev/null 2>&1; then
    TUTORIAL_COMMITS=$(git rev-list --count HEAD)
    LAST_COMMIT=$(git log -1 --format="%h - %s")
    log_action "   CoreAudioTutorial: $TUTORIAL_COMMITS commit(s)"
    log_action "   Latest: $LAST_COMMIT"
else
    log_action "   CoreAudioTutorial: No commits"
fi

echo

# Create Day 1 completion marker
DAY1_COMPLETION_FILE="$LOGS_DIR/day01_completed.marker"
echo "Day 1 completed and committed: $TIMESTAMP" > "$DAY1_COMPLETION_FILE"

echo "======================================================================="
if [[ "$COMMIT_SUCCESS" == true ]]; then
    echo "✅ DAY 1 SUCCESSFULLY COMMITTED!"
    echo
    echo "🎉 Congratulations! You have completed Day 1 of the Core Audio Tutorial"
    echo "   All foundation work has been saved to your repositories."
    echo
    echo "📊 What was committed:"
    echo "   📁 Complete directory structure for both repositories"
    echo "   🔧 Environment configuration and activation scripts"
    echo "   🧪 Testing frameworks (Unity, GoogleTest)"
    echo "   📝 Build system and validation scripts"
    echo "   📋 Session logging and progress tracking"
    echo
    echo "🚀 Ready for Day 2!"
    echo "   Run: ./day02_step01_shared_foundation.sh"
    echo
    echo "📍 Your progress is saved in:"
    echo "   CoreAudioMastery: $CORE_AUDIO_ROOT"
    echo "   CoreAudioTutorial: $TUTORIAL_ROOT"
    echo "   Session logs: $LOGS_DIR"
else
    echo "⚠️  DAY 1 COMMIT ISSUES"
    echo
    echo "Some repositories may not have committed successfully."
    echo "Please review the messages above and resolve any issues."
    echo
    echo "You can:"
    echo "1. Check repository status manually"
    echo "2. Re-run this script after fixing issues"
    echo "3. Commit manually if needed"
fi
echo "======================================================================="

# Log completion
log_action "📅 Day 1 commit process completed"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-COMMIT-COMPLETE] Day 1 commit process completed" >> "$LOGS_DIR/day01_session.log"

# Return appropriate exit code
if [[ "$COMMIT_SUCCESS" == true ]]; then
    exit 0
else
    exit 1
fi
