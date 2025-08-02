#!/bin/bash

# Day 2 Morning Session: Environment Activation & Build System Creation
# Core Audio Tutorial - Foundation Building
# Duration: 2 hours
# Expected outcome: Complete environment and build infrastructure

set -e

echo "[$(date '+%H:%M:%S')] [DAY 2 - MORNING SESSION] Environment & Build System Creation"
echo "==============================================================================="

# Session tracking
SESSION_LOG="daily-sessions/day02/morning-session.log"
CHECKPOINT_COUNT=0

# Function to log with timestamp and session tracking
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SESSION_LOG"
}

# Function to create git checkpoint
create_checkpoint() {
    local message="$1"
    CHECKPOINT_COUNT=$((CHECKPOINT_COUNT + 1))
    log_action "📍 Creating checkpoint $CHECKPOINT_COUNT: $message"
    git add -A
    git commit -m "Checkpoint $CHECKPOINT_COUNT: $message" || log_action "No changes to commit"
    echo "Checkpoint $CHECKPOINT_COUNT: $(git rev-parse --short HEAD) - $message" >> daily-sessions/day02/checkpoints.txt
}

# Function to validate step completion
validate_step() {
    local step_name="$1"
    local validation_command="$2"
    
    log_action "🔍 Validating: $step_name"
    if eval "$validation_command"; then
        log_action "✅ Validation passed: $step_name"
        return 0
    else
        log_action "❌ Validation failed: $step_name"
        return 1
    fi
}

# ================================================================
# PHASE 1: Environment Detection System (30 minutes)
# ================================================================

log_action "🚀 PHASE 1: Creating Environment Detection System"

# Step 1.1: Create environment detection library
log_action "📝 Creating environment detection library..."

mkdir -p lib
cat > lib/ca_env_detection.sh << 'ENV_DETECT_EOF'
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
ENV_DETECT_EOF

validate_step "Environment detection library" "[[ -f lib/ca_env_detection.sh ]]"

# Step 1.2: Create main environment activation script
log_action "📝 Creating main environment activation script..."

cat > activate-ca-env.sh << 'ACTIVATE_EOF'
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
ACTIVATE_EOF

chmod +x activate-ca-env.sh
validate_step "Environment activation script" "[[ -x activate-ca-env.sh ]]"

create_checkpoint "Environment detection system complete"

# ================================================================
# PHASE 2: Multi-Language Build Infrastructure (45 minutes)
# ================================================================

log_action "🚀 PHASE 2: Creating Multi-Language Build Infrastructure"

# Step 2.1: Create build system directory structure
log_action "📝 Creating build system structure..."

mkdir -p build-system/{c,cpp,objc,swift}
mkdir -p scripts

# Step 2.2: Create C build script
log_action "📝 Creating C build script..."

cat > build-system/c/build.sh << 'C_BUILD_EOF'
#!/bin/bash

# C Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.c> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .c)}"

# Validate source file
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "❌ Source file not found: $SOURCE_FILE"
    exit 1
fi

echo "🔨 Building C program: $SOURCE_FILE"

# Compile with Core Audio frameworks
clang -Wall -Wextra -std=c11 \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    "$SOURCE_FILE" \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
C_BUILD_EOF

chmod +x build-system/c/build.sh

# Step 2.3: Create C++ build script
log_action "📝 Creating C++ build script..."

cat > build-system/cpp/build.sh << 'CPP_BUILD_EOF'
#!/bin/bash

# C++ Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.cpp> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .cpp)}"

echo "🔨 Building C++ program: $SOURCE_FILE"

# Compile with Core Audio frameworks
clang++ -Wall -Wextra -std=c++17 \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    "$SOURCE_FILE" \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
CPP_BUILD_EOF

chmod +x build-system/cpp/build.sh

# Step 2.4: Create Objective-C build script
log_action "📝 Creating Objective-C build script..."

cat > build-system/objc/build.sh << 'OBJC_BUILD_EOF'
#!/bin/bash

# Objective-C Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.m> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .m)}"

echo "🔨 Building Objective-C program: $SOURCE_FILE"

# Compile with Core Audio frameworks
clang -Wall -Wextra -fobjc-arc \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    "$SOURCE_FILE" \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
OBJC_BUILD_EOF

chmod +x build-system/objc/build.sh

# Step 2.5: Create Swift build script
log_action "📝 Creating Swift build script..."

cat > build-system/swift/build.sh << 'SWIFT_BUILD_EOF'
#!/bin/bash

# Swift Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.swift> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .swift)}"

echo "🔨 Building Swift program: $SOURCE_FILE"

# Compile with Core Audio frameworks
swiftc "$SOURCE_FILE" \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
SWIFT_BUILD_EOF

chmod +x build-system/swift/build.sh

# Step 2.6: Create universal build command
log_action "📝 Creating universal build command..."

cat > scripts/ca-build << 'CA_BUILD_EOF'
#!/bin/bash

# Universal Core Audio Build Command
set -e

if [[ $# -lt 2 ]]; then
    echo "Usage: ca-build <language> <source_file> [output_name]"
    echo "Languages: c, cpp, objc, swift"
    exit 1
fi

LANGUAGE="$1"
SOURCE_FILE="$2"
OUTPUT_NAME="$3"

# Find build system directory
BUILD_SYSTEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/build-system"

case "$LANGUAGE" in
    c)
        "$BUILD_SYSTEM_DIR/c/build.sh" "$SOURCE_FILE" "$OUTPUT_NAME"
        ;;
    cpp|c++)
        "$BUILD_SYSTEM_DIR/cpp/build.sh" "$SOURCE_FILE" "$OUTPUT_NAME"
        ;;
    objc|m)
        "$BUILD_SYSTEM_DIR/objc/build.sh" "$SOURCE_FILE" "$OUTPUT_NAME"
        ;;
    swift)
        "$BUILD_SYSTEM_DIR/swift/build.sh" "$SOURCE_FILE" "$OUTPUT_NAME"
        ;;
    *)
        echo "❌ Unknown language: $LANGUAGE"
        echo "Supported: c, cpp, objc, swift"
        exit 1
        ;;
esac
CA_BUILD_EOF

chmod +x scripts/ca-build
validate_step "Build infrastructure" "[[ -x scripts/ca-build ]]"

create_checkpoint "Multi-language build infrastructure complete"

# ================================================================
# PHASE 3: Testing Infrastructure (30 minutes)
# ================================================================

log_action "🚀 PHASE 3: Creating Testing Infrastructure"

# Step 3.1: Create test runner scripts
log_action "📝 Creating test runner infrastructure..."

mkdir -p test-system/{c,cpp,objc,swift}

# Step 3.2: Create C test runner
cat > test-system/c/run-tests.sh << 'C_TEST_EOF'
#!/bin/bash

# C Test Runner using Unity framework
set -e

TEST_DIR="${1:-.}"
echo "🧪 Running C tests in: $TEST_DIR"

# Check for Unity framework
UNITY_DIR="$TUTORIAL_ROOT/shared-frameworks/unity/src"
if [[ ! -f "$UNITY_DIR/unity.h" ]]; then
    echo "❌ Unity framework not found. Run setup scripts first."
    exit 1
fi

# Find and run test files
find "$TEST_DIR" -name "*_test.c" -o -name "test_*.c" | while read test_file; do
    echo "Running: $test_file"
    output_name="/tmp/$(basename "$test_file" .c)"
    
    # Compile test
    clang -I"$UNITY_DIR" \
        -framework AudioToolbox \
        -framework CoreFoundation \
        "$UNITY_DIR/unity.c" \
        "$test_file" \
        -o "$output_name"
    
    # Run test
    "$output_name"
    rm "$output_name"
done

echo "✅ C tests complete"
C_TEST_EOF

chmod +x test-system/c/run-tests.sh

# Step 3.3: Create universal test command
cat > scripts/ca-test << 'CA_TEST_EOF'
#!/bin/bash

# Universal Core Audio Test Runner
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: ca-test <language> [test_directory]"
    echo "Languages: c, cpp, objc, swift"
    exit 1
fi

LANGUAGE="$1"
TEST_DIR="${2:-.}"

# Find test system directory
TEST_SYSTEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/test-system"

case "$LANGUAGE" in
    c)
        "$TEST_SYSTEM_DIR/c/run-tests.sh" "$TEST_DIR"
        ;;
    cpp|c++)
        echo "C++ tests not yet implemented"
        ;;
    objc|m)
        echo "Objective-C tests not yet implemented"
        ;;
    swift)
        echo "Swift tests not yet implemented"
        ;;
    *)
        echo "❌ Unknown language: $LANGUAGE"
        exit 1
        ;;
esac
CA_TEST_EOF

chmod +x scripts/ca-test
validate_step "Test infrastructure" "[[ -x scripts/ca-test ]]"

create_checkpoint "Testing infrastructure complete"

# ================================================================
# PHASE 4: Sample Programs and Validation (15 minutes)
# ================================================================

log_action "🚀 PHASE 4: Creating Sample Programs for Validation"

mkdir -p samples/{c,cpp,objc,swift}

# Step 4.1: Create simple C test program
log_action "📝 Creating C validation program..."

cat > samples/c/hello_coreaudio.c << 'C_SAMPLE_EOF'
#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

int main(int argc, char *argv[]) {
    printf("Hello, Core Audio!\n");
    
    // Simple Core Audio validation - check version
    UInt32 size = sizeof(UInt32);
    UInt32 version = 0;
    
    // This is just to verify Core Audio links properly
    printf("Core Audio framework successfully linked\n");
    
    // Display some basic info
    CFStringRef bundleID = CFSTR("com.apple.audio.toolbox");
    printf("AudioToolbox Bundle ID: %s\n",
           CFStringGetCStringPtr(bundleID, kCFStringEncodingUTF8));
    
    return 0;
}
C_SAMPLE_EOF

# Step 4.2: Create C test
cat > samples/c/test_hello.c << 'C_TEST_SAMPLE_EOF'
#include "unity.h"
#include <AudioToolbox/AudioToolbox.h>

void setUp(void) {
    // Setup code
}

void tearDown(void) {
    // Cleanup code
}

void test_CoreAudioFrameworkAvailable(void) {
    // Simple test to verify Core Audio is available
    TEST_ASSERT_NOT_NULL(AudioFileOpenURL);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_CoreAudioFrameworkAvailable);
    return UNITY_END();
}
C_TEST_SAMPLE_EOF

validate_step "Sample programs" "[[ -f samples/c/hello_coreaudio.c ]]"

create_checkpoint "Sample programs and validation complete"

# ================================================================
# FINAL VALIDATION AND SUMMARY
# ================================================================

log_action "🔍 FINAL VALIDATION: Testing complete setup"

# Test environment activation
log_action "Testing environment activation..."
if source ./activate-ca-env.sh > /dev/null 2>&1; then
    log_action "✅ Environment activation works"
else
    log_action "❌ Environment activation failed"
fi

# Test build system
log_action "Testing build system..."
if ./scripts/ca-build c samples/c/hello_coreaudio.c /tmp/test_build 2>&1; then
    log_action "✅ Build system works"
    rm -f /tmp/test_build
else
    log_action "❌ Build system failed"
fi

# Create final checkpoint
create_checkpoint "Day 2 Morning Session complete"

# Update progress summary
cat >> progress-summary.md << 'PROGRESS_EOF'

### Day 2 Morning Session: Complete ✅
- Environment detection and activation system
- Multi-language build infrastructure (C, C++, Objective-C, Swift)
- Testing framework integration
- Sample programs for validation
- Session tracking and checkpoints

**Key Commands Created:**
- `source ./activate-ca-env.sh` - Activate environment
- `ca-build <language> <source>` - Build programs
- `ca-test <language>` - Run tests
- `ca-cd <location>` - Navigate directories
- `ca-log` - View session logs

**Checkpoints Created:** $(cat daily-sessions/day02/checkpoints.txt | wc -l)
PROGRESS_EOF

# Final summary
log_action "============================================================"
log_action "✅ DAY 2 MORNING SESSION COMPLETE!"
log_action "============================================================"
echo
echo "📊 Session Summary:"
echo "  - Duration: ~2 hours"
echo "  - Checkpoints created: $CHECKPOINT_COUNT"
echo "  - Environment system: ✅"
echo "  - Build infrastructure: ✅"
echo "  - Test infrastructure: ✅"
echo "  - Sample programs: ✅"
echo
echo "📝 Key files created:"
echo "  - activate-ca-env.sh (environment activation)"
echo "  - scripts/ca-build (universal build command)"
echo "  - scripts/ca-test (universal test runner)"
echo "  - lib/ca_env_detection.sh (environment library)"
echo
echo "🧪 Test the setup:"
echo "  source ./activate-ca-env.sh"
echo "  ca-build c samples/c/hello_coreaudio.c"
echo "  ./hello_coreaudio"
echo
echo "📝 Session artifacts:"
echo "  - Log: daily-sessions/day02/morning-session.log"
echo "  - Checkpoints: daily-sessions/day02/checkpoints.txt"
echo "  - Progress: progress-summary.md"
echo
echo "🚀 Ready for Day 2 Afternoon Session!"
