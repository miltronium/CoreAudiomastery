
#!/bin/bash

# Quick verification script to check tutorial scripts location and contents

echo "🔍 Tutorial Scripts Verification"
echo "================================"

ORIGINAL_DIR=$(pwd)
echo "📁 Current directory: $ORIGINAL_DIR"
echo "📁 Directory basename: $(basename "$ORIGINAL_DIR")"

echo
echo "📊 Files in current directory:"
ls -la

echo
echo "🔍 Looking for tutorial script files:"
find . -maxdepth 1 -name "*.sh" -o -name "*.md" | head -10

echo
echo "📁 Checking for tutorial-scripts subdirectory:"
if [[ -d "tutorial-scripts" ]]; then
    echo "✅ Found tutorial-scripts subdirectory"
    echo "   Contents:"
    ls -la tutorial-scripts/ | head -5
else
    echo "❌ No tutorial-scripts subdirectory found"
fi

echo
echo "🎯 Archive script strategy:"
if [[ "$(basename "$ORIGINAL_DIR")" == "tutorial-scripts" ]]; then
    echo "✅ Running from within tutorial-scripts directory"
    echo "   Will archive current directory contents"
elif [[ -d "tutorial-scripts" ]]; then
    echo "✅ Found tutorial-scripts subdirectory"
    echo "   Will archive subdirectory contents"
else
    echo "⚠️  Neither condition met - archive may not find files"
fi

echo
echo "🔍 Checking for CoreAudio environment:"
if [[ -f "../.core-audio-env" ]]; then
    echo "✅ Found environment file: ../.core-audio-env"
    source "../.core-audio-env"
    echo "   CORE_AUDIO_ROOT: $CORE_AUDIO_ROOT"
    echo "   TUTORIAL_ROOT: $TUTORIAL_ROOT"
elif [[ -f ".core-audio-env" ]]; then
    echo "✅ Found environment file: .core-audio-env"
    source ".core-audio-env"
    echo "   CORE_AUDIO_ROOT: $CORE_AUDIO_ROOT"
    echo "   TUTORIAL_ROOT: $TUTORIAL_ROOT"
else
    echo "⚠️  No environment file found"
fi

echo
echo "✅ Verification complete. Ready to run archive script."
