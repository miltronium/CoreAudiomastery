#!/bin/bash

# Test Chapter 1 implementations

echo "🧪 Testing Chapter 1 Basic Implementation"
echo "========================================"

# Save current directory
TUTORIAL_SCRIPTS_DIR=$(pwd)

# Move to Chapter 1 directory
cd ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic

# Build using make
echo "🔨 Building CAMetadata with make..."
if make; then
    echo "✅ Build successful"
    
    # Test with a system sound
    echo
    echo "🎵 Testing with system sound..."
    if [[ -f "/System/Library/Sounds/Ping.aiff" ]]; then
        ./CAMetadata "/System/Library/Sounds/Ping.aiff"
    else
        echo "ℹ️  System sound not found. Usage:"
        echo "   ./CAMetadata /path/to/audiofile"
    fi
else
    echo "❌ Build failed"
fi

# Return to tutorial-scripts
cd "$TUTORIAL_SCRIPTS_DIR"
