#!/bin/bash

# Day 1 - Step 2: Automated Repository Initialization
# Core Audio Tutorial - Setup and Foundation

set -e

echo "[$(date '+%H:%M:%S')] [DAY 1 - STEP 2] Automated Repository Initialization"
echo "========================================================================"

# Function to find and source environment file
find_and_source_env() {
    local env_file=""
    local search_paths=(
        "../.core-audio-env"
        ".core-audio-env"
        "$HOME/Development/CoreAudio/.core-audio-env"
        "../../.core-audio-env"
        "../../../.core-audio-env"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then
            env_file="$path"
            break
        fi
    done
    
    if [[ -n "$env_file" ]]; then
        echo "[$(date '+%H:%M:%S')] 📍 Found environment file: $env_file"
        source "$env_file"
        return 0
    else
        echo "[$(date '+%H:%M:%S')] ⚠️  Environment file not found, trying to detect from current location"
        return 1
    fi
}

# Enhanced environment detection
detect_environment_from_location() {
    echo "[$(date '+%H:%M:%S')] 🔍 Attempting to detect environment from directory structure"
    
    CURRENT_DIR=$(pwd)
    if [[ -d "CoreAudioMastery" && -d "CoreAudioTutorial" ]]; then
        # We're in the base directory
        export CORE_AUDIO_ROOT="$CURRENT_DIR/CoreAudioMastery"
        export TUTORIAL_ROOT="$CURRENT_DIR/CoreAudioTutorial"
        export LOGS_DIR="$CURRENT_DIR/logs"
        echo "[$(date '+%H:%M:%S')] ✅ Detected environment from current directory"
        return 0
    elif [[ -d "../CoreAudioMastery" && -d "../CoreAudioTutorial" ]]; then
        # We're one level down
        export CORE_AUDIO_ROOT="$(dirname "$CURRENT_DIR")/CoreAudioMastery"
        export TUTORIAL_ROOT="$(dirname "$CURRENT_DIR")/CoreAudioTutorial"
        export LOGS_DIR="$(dirname "$CURRENT_DIR")/logs"
        echo "[$(date '+%H:%M:%S')] ✅ Detected environment from parent directory"
        return 0
    elif [[ $(basename "$CURRENT_DIR") == "CoreAudioTutorial" ]]; then
        # We're in the tutorial directory
        BASE_DIR="$(dirname "$CURRENT_DIR")"
        export CORE_AUDIO_ROOT="$BASE_DIR/CoreAudioMastery"
        export TUTORIAL_ROOT="$CURRENT_DIR"
        export LOGS_DIR="$BASE_DIR/logs"
        echo "[$(date '+%H:%M:%S')] ✅ Detected environment from CoreAudioTutorial directory"
        return 0
    else
        echo "[$(date '+%H:%M:%S')] ❌ Could not detect environment from current location"
        return 1
    fi
}

# Source environment with enhanced detection
if ! find_and_source_env; then
    detect_environment_from_location
fi

# Function to log with timestamp and Day 1 session tracking
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    if [[ -n "$LOGS_DIR" && -d "$LOGS_DIR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-STEP2] $1" >> "$LOGS_DIR/day01_session.log"
    fi
}

# Git setup functions
is_git_repo() {
    local dir="$1"
    cd "$dir" && git rev-parse --git-dir > /dev/null 2>&1
}

init_git_repo() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_action "🔧 Setting up git repository: $repo_name"
    
    cd "$repo_path"
    
    if is_git_repo "$repo_path"; then
        log_action "ℹ️  Git repository already exists in $repo_name"
    else
        git init
        log_action "✅ Git repository initialized: $repo_name"
    fi
}

# Validate environment
if [[ -z "$CORE_AUDIO_ROOT" || -z "$TUTORIAL_ROOT" ]]; then
    log_action "❌ Environment variables not set. Run step01 first."
    exit 1
fi

log_action "✅ Environment validation passed"

# Initialize repositories
log_action "📂 Setting up CoreAudioMastery repository (Study Guide)"
init_git_repo "$CORE_AUDIO_ROOT" "CoreAudioMastery"

log_action "📂 Setting up CoreAudioTutorial repository (Tutorial)"
init_git_repo "$TUTORIAL_ROOT" "CoreAudioTutorial"

log_action "🎯 Day 1 - Step 2 Complete: Repository initialization!"
