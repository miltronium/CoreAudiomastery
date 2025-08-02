#!/bin/bash

# Core Audio Tutorial Environment Activation
# Source this script to activate the Core Audio development environment

# Source the detection library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ca_env_detection.sh"

# Detect Core Audio root
echo "🔍 Detecting Core Audio environment..."
if CA_ROOT=$(detect_ca_root); then
    echo "✅ Found Core Audio root: $CA_ROOT"
else
    echo "❌ Could not detect Core Audio environment"
    echo "Please ensure you have run the setup scripts"
    return 1 2>/dev/null || exit 1
fi

# Validate environment
echo "🔍 Validating environment..."
if validation_result=$(validate_ca_environment "$CA_ROOT" 2>&1); then
    echo "✅ Environment validation passed"
else
    echo "❌ Environment validation failed:"
    echo "$validation_result"
    return 1 2>/dev/null || exit 1
fi

# Setup environment variables
setup_ca_environment "$CA_ROOT"

# Show environment
echo
show_ca_environment
echo

# Create convenience functions
ca-cd() {
    case "$1" in
        tutorial|t)
            cd "$TUTORIAL_ROOT"
            ;;
        mastery|m)
            cd "$CORE_AUDIO_ROOT"
            ;;
        logs|l)
            cd "$LOGS_DIR"
            ;;
        *)
            echo "Usage: ca-cd [tutorial|t|mastery|m|logs|l]"
            ;;
    esac
}

ca-log() {
    tail -f "$LOGS_DIR/day$(date +%d)_session.log"
}

echo "✅ Core Audio environment activated!"
echo "Commands available:"
echo "  ca-cd [tutorial|mastery|logs] - Navigate to directories"
echo "  ca-log - View today's session log"
echo "  ca-build - Build Core Audio programs (after setup)"
echo "  ca-test - Run tests (after setup)"
