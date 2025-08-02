#!/bin/bash

# Fixed Archive Tutorial Scripts - Complete Implementation
# Fixes missing function definitions and improves functionality

set -e

echo "[$(date '+%H:%M:%S')] 📦 Archive Tutorial Scripts - Fixed Version"
echo "============================================================"

# Save original directory and set up logging
ORIGINAL_DIR=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="archive_log_${TIMESTAMP}.log"

# Enhanced logging function
log_action() {
    local message="$1"
    echo "[$(date '+%H:%M:%S')] $message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

log_action "🔧 Starting archive script with fixes"
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

# FIXED: Add missing archive_scripts function
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
Complete tutorial setup scripts generated for Days 1-2:
- `step01_create_directories.sh` - Directory structure setup
- `step02_initialize_repos.sh` - Git repository initialization
- `step03_setup_environment.sh` - Environment configuration
- `step04_install_frameworks.sh` - Testing framework installation

### scripts/
Additional setup and utility scripts:
- Setup generators and environment scripts
- Validation and testing utilities

### logs/
Session logs from tutorial setup process:
- Day 1 and Day 2 session tracking
- Setup validation logs
- Environment configuration history

## Usage

These scripts were generated during the tutorial setup process and are archived
for reference and potential reuse. They represent the complete setup workflow
for the Core Audio mastery tutorial.

## Next Steps

With setup complete, continue with the main tutorial implementation following
the study schedule and session structure.
ARCHIVE_README_EOF

    log_action "✅ Archive complete: $description"
    return 0
}

# FIXED: Add missing copy_to_study_guide function
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
    
    # Create study guide setup documentation
    cat > "$study_guide_root/setup/SETUP_ARCHIVE.md" << 'SETUP_ARCHIVE_EOF'
# Core Audio Study Guide - Setup Archive

This directory contains the complete setup process archive from the tutorial
development phase.

## Contents

- `tutorial-scripts/` - Day 1-2 setup scripts for environment configuration
- `session-logs/` - Complete session logs from setup process
- Setup documentation and validation scripts

## Purpose

These archived materials serve as:
1. Reference for setup process validation
2. Backup for development environment recreation
3. Documentation of tutorial progression methodology
4. Foundation for future chapter implementations

## Integration

This setup archive integrates with the main study guide repository structure
and provides the foundation for Chapter 1 implementation across all languages.
SETUP_ARCHIVE_EOF

    log_action "✅ Study guide archive complete"
    return 0
}

# Main execution
main() {
    log_action "🎯 Starting main archive process"
    
    # Detect environment
    if ! detect_environment; then
        log_action "❌ Environment detection failed"
        exit 1
    fi
    
    # Display menu
    echo
    echo "📦 Archive Tutorial Scripts - Fixed Version"
    echo "============================================"
    echo
    echo "Available archive destinations:"
    echo "1. CoreAudioMastery repository (study guide)"
    echo "2. CoreAudioTutorial repository (tutorial)"
    echo "3. Both repositories"
    echo "4. Custom location"
    echo "5. Exit"
    echo
    
    read -p "Choose option (1/2/3/4/5): " choice
    
    case $choice in
        1)
            if [[ -d "$CORE_AUDIO_ROOT" ]]; then
                archive_scripts "$CORE_AUDIO_ROOT" "CoreAudioMastery"
                copy_to_study_guide "$CORE_AUDIO_ROOT"
                log_action "🎯 Archived to CoreAudioMastery repository"
            else
                log_action "❌ CoreAudioMastery directory not found: $CORE_AUDIO_ROOT"
                exit 1
            fi
            ;;
        2)
            if [[ -d "$TUTORIAL_ROOT" ]]; then
                archive_scripts "$TUTORIAL_ROOT" "CoreAudioTutorial"
                log_action "🎯 Archived to CoreAudioTutorial repository"
            else
                log_action "❌ CoreAudioTutorial directory not found: $TUTORIAL_ROOT"
                exit 1
            fi
            ;;
        3)
            if [[ -d "$CORE_AUDIO_ROOT" && -d "$TUTORIAL_ROOT" ]]; then
                archive_scripts "$CORE_AUDIO_ROOT" "CoreAudioMastery"
                copy_to_study_guide "$CORE_AUDIO_ROOT"
                archive_scripts "$TUTORIAL_ROOT" "CoreAudioTutorial"
                log_action "🎯 Archived to both repositories"
            else
                log_action "❌ One or both repositories not found"
                log_action "   CoreAudioMastery: $CORE_AUDIO_ROOT"
                log_action "   CoreAudioTutorial: $TUTORIAL_ROOT"
                exit 1
            fi
            ;;
        4)
            read -p "Enter custom archive path: " custom_path
            if [[ -n "$custom_path" ]]; then
                mkdir -p "$custom_path"
                archive_scripts "$custom_path" "custom location ($custom_path)"
                log_action "🎯 Archived to custom location: $custom_path"
            else
                log_action "❌ No custom path provided"
                exit 1
            fi
            ;;
        5)
            log_action "👋 Archive cancelled by user"
            exit 0
            ;;
        *)
            log_action "❌ Invalid option: $choice"
            exit 1
            ;;
    esac
    
    # Final status
    echo
    log_action "✅ Archive process completed successfully"
    log_action "📄 Session log: $LOG_FILE"
    echo
    echo "🚀 Ready for next tutorial phase!"
    echo
    
    return 0
}

# Execute main function
main "$@"
