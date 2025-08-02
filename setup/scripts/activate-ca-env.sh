#!/bin/bash
# Core Audio Tutorial Environment Activation
if [[ -f "../.core-audio-env" ]]; then
    source "../.core-audio-env"
elif [[ -f ".core-audio-env" ]]; then
    source ".core-audio-env"
fi
validate_environment() {
    echo "🔍 Validating Core Audio environment..."
    if [[ -d "$CORE_AUDIO_ROOT" && -d "$TUTORIAL_ROOT" ]]; then
        echo "✓ Repository paths valid"
    else
        echo "✗ Repository paths invalid"
        return 1
    fi
    if echo "#include <AudioToolbox/AudioToolbox.h>" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
        echo "✓ Core Audio framework accessible"
    else
        echo "✗ Core Audio framework not accessible"
        return 1
    fi
    echo "Environment validation passed ✓"
    return 0
}
echo "Core Audio Tutorial Environment Activated"
echo "Tutorial Root: $TUTORIAL_ROOT"
