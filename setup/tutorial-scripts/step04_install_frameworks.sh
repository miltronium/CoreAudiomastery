#!/bin/bash

# Day 1 - Step 4: Automated Framework Installation
# Core Audio Tutorial - Setup and Foundation

set -e

echo "[$(date '+%H:%M:%S')] [DAY 1 - STEP 4] Automated Framework Installation"
echo "========================================================================="

# Source environment
if [[ -f "../.core-audio-env" ]]; then
    source "../.core-audio-env"
elif [[ -f ".core-audio-env" ]]; then
    source ".core-audio-env"
elif [[ -f "$HOME/Development/CoreAudio/.core-audio-env" ]]; then
    source "$HOME/Development/CoreAudio/.core-audio-env"
fi

# Function to log with timestamp and Day 1 session tracking
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    if [[ -n "$LOGS_DIR" && -d "$LOGS_DIR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-STEP4] $1" >> "$LOGS_DIR/day01_session.log"
    fi
}

# Main execution
log_action "🎯 Starting framework installation for Day 1"

# Validate prerequisites
if [[ -z "$TUTORIAL_ROOT" ]]; then
    log_action "❌ TUTORIAL_ROOT not set. Run previous steps first."
    exit 1
fi

cd "$TUTORIAL_ROOT"

# Create shared-frameworks directory
mkdir -p shared-frameworks

# Install Unity framework
log_action "🧪 Installing Unity testing framework for C"
mkdir -p shared-frameworks/unity/src

# Download Unity source files
log_action "⬇️  Downloading Unity source files"
if curl -L "https://raw.githubusercontent.com/ThrowTheSwitch/Unity/master/src/unity.c" \
     -o "shared-frameworks/unity/src/unity.c" && \
   curl -L "https://raw.githubusercontent.com/ThrowTheSwitch/Unity/master/src/unity.h" \
     -o "shared-frameworks/unity/src/unity.h" && \
   curl -L "https://raw.githubusercontent.com/ThrowTheSwitch/Unity/master/src/unity_internals.h" \
     -o "shared-frameworks/unity/src/unity_internals.h"; then
    log_action "✅ Unity framework downloaded successfully"
else
    log_action "❌ Failed to download Unity source files"
fi

# Install GoogleTest framework
log_action "🧪 Installing GoogleTest framework for C++"
if git clone --depth 1 https://github.com/google/googletest.git shared-frameworks/googletest; then
    log_action "✅ GoogleTest cloned successfully"
else
    log_action "❌ Failed to clone GoogleTest repository"
fi

# Create validation script with correct path detection
mkdir -p scripts
cat > scripts/validate-frameworks.sh << 'VALIDATE_EOF'
#!/bin/bash

echo "🔍 Validating testing framework installation..."

# Determine correct path to shared-frameworks
FRAMEWORKS_DIR=""
if [[ -d "shared-frameworks" ]]; then
    FRAMEWORKS_DIR="shared-frameworks"
elif [[ -d "../shared-frameworks" ]]; then
    FRAMEWORKS_DIR="../shared-frameworks"
else
    echo "❌ Cannot locate shared-frameworks directory"
    exit 1
fi

# Check Unity framework
if [[ -f "$FRAMEWORKS_DIR/unity/src/unity.h" && -f "$FRAMEWORKS_DIR/unity/src/unity.c" ]]; then
    echo "✅ Unity framework found and complete"
else
    echo "❌ Unity framework missing or incomplete"
fi

# Check GoogleTest framework
if [[ -d "$FRAMEWORKS_DIR/googletest" && -f "$FRAMEWORKS_DIR/googletest/CMakeLists.txt" ]]; then
    echo "✅ GoogleTest framework found"
else
    echo "❌ GoogleTest framework missing"
fi

echo "Framework validation complete"
VALIDATE_EOF

chmod +x scripts/validate-frameworks.sh

# Run validation
log_action "🔍 Validating framework installation"
./scripts/validate-frameworks.sh

# Final status
log_action "🎯 Day 1 - Step 4 Complete: Framework installation!"
echo
echo "🎉 Day 1 Complete: Setup and Foundation!"
echo "   📋 Session log: logs/day01_session.log"
echo
echo "🚀 Ready for Day 2: Foundation Building"
echo "   cd ~/Development/CoreAudio/CoreAudioTutorial"

# Log Day 1 completion
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-COMPLETE] Day 1 Setup and Foundation completed successfully" >> "$LOGS_DIR/day01_session.log"
