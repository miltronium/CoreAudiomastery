#!/bin/bash

# Day 2 Status Check Script
echo "📊 Day 2 Morning Session Status Check"
echo "====================================="
echo

# Check environment
echo "🔍 Checking environment activation..."
if [[ -n "$TUTORIAL_ROOT" ]]; then
    echo "✅ Environment variables set"
    echo "   TUTORIAL_ROOT: $TUTORIAL_ROOT"
    echo "   CORE_AUDIO_ROOT: $CORE_AUDIO_ROOT"
else
    echo "❌ Environment not activated. Run: source ./activate-ca-env.sh"
fi
echo

# Check build system
echo "🔍 Checking build system..."
if [[ -x scripts/ca-build ]]; then
    echo "✅ Build scripts exist and are executable"
else
    echo "❌ Build scripts missing"
fi
echo

# Check git status
echo "🔍 Checking git status..."
echo "Current branch: $(git branch --show-current)"
echo "Last commit: $(git log -1 --oneline)"
echo

# Check checkpoints
echo "📍 Git checkpoints created:"
if [[ -f daily-sessions/day02/checkpoints.txt ]]; then
    cat daily-sessions/day02/checkpoints.txt
else
    echo "No checkpoints file found"
fi
echo

echo "✅ Status check complete!"
echo
echo "Next: Run ./day02_test_languages.sh to test all language builds"
