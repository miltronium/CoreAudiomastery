#!/bin/bash

# Core Audio Environment Detection Library
# Provides functions for detecting and validating environment

# Function to detect Core Audio development root
detect_ca_root() {
    local current_dir=$(pwd)
    
    # Check various possible locations
    if [[ -d "$HOME/Development/CoreAudio" ]]; then
        echo "$HOME/Development/CoreAudio"
        return 0
    elif [[ -d "../CoreAudioMastery" && -d "../CoreAudioTutorial" ]]; then
        echo "$(dirname "$current_dir")"
        return 0
    elif [[ -d "CoreAudioMastery" && -d "CoreAudioTutorial" ]]; then
        echo "$current_dir"
        return 0
    else
        return 1
    fi
}

# Function to validate Core Audio environment
validate_ca_environment() {
    local ca_root="$1"
    
    # Check required directories
    local required_dirs=(
        "$ca_root/CoreAudioMastery"
        "$ca_root/CoreAudioTutorial"
        "$ca_root/logs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "Missing required directory: $dir"
            return 1
        fi
    done
    
    # Check Xcode tools
    if ! command -v clang > /dev/null 2>&1; then
        echo "Xcode command line tools not found"
        return 1
    fi
    
    # Check Core Audio framework
    if ! echo "#include <AudioToolbox/AudioToolbox.h>" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
        echo "Core Audio framework not accessible"
        return 1
    fi
    
    return 0
}

# Function to setup environment variables
setup_ca_environment() {
    local ca_root="$1"
    
    export CORE_AUDIO_ROOT="$ca_root/CoreAudioMastery"
    export TUTORIAL_ROOT="$ca_root/CoreAudioTutorial"
    export LOGS_DIR="$ca_root/logs"
    export CA_TUTORIAL_BASE="$ca_root"
    
    # Add scripts directory to PATH
    export PATH="$TUTORIAL_ROOT/scripts:$PATH"
}

# Function to display environment info
show_ca_environment() {
    echo "Core Audio Development Environment:"
    echo "  Base: $CA_TUTORIAL_BASE"
    echo "  Tutorial: $TUTORIAL_ROOT"
    echo "  Mastery: $CORE_AUDIO_ROOT"
    echo "  Logs: $LOGS_DIR"
    echo "  Clang: $(clang --version | head -1)"
}
