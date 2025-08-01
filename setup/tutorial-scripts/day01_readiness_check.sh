#!/bin/bash

# Day 1 Readiness Check - Comprehensive Validation
# Core Audio Tutorial - Ensures Day 1 completion before Day 2

set -e

echo "======================================================================="
echo "[$(date '+%H:%M:%S')] 🔍 CORE AUDIO TUTORIAL - DAY 1 READINESS CHECK"
echo "======================================================================="
echo

# Global validation state
VALIDATION_PASSED=true
ISSUES_FOUND=()
WARNINGS_FOUND=()

# Enhanced logging with validation tracking
log_check() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "PASS")
            echo "✅ $message"
            ;;
        "FAIL")
            echo "❌ $message"
            VALIDATION_PASSED=false
            ISSUES_FOUND+=("$message")
            ;;
        "WARN")
            echo "⚠️  $message"
            WARNINGS_FOUND+=("$message")
            ;;
        "INFO")
            echo "ℹ️  $message"
            ;;
        *)
            echo "📋 $message"
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a directory exists and is accessible
check_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        if [[ -r "$dir" && -w "$dir" ]]; then
            log_check "PASS" "Directory accessible: $description ($dir)"
            return 0
        else
            log_check "FAIL" "Directory not accessible: $description ($dir)"
            return 1
        fi
    else
        log_check "FAIL" "Directory missing: $description ($dir)"
        return 1
    fi
}

# Function to check if a file exists and is readable
check_file() {
    local file="$1"
    local description="$2"
    local required="$3"  # "required" or "optional"
    
    if [[ -f "$file" ]]; then
        if [[ -r "$file" ]]; then
            log_check "PASS" "File found: $description ($file)"
            return 0
        else
            log_check "FAIL" "File not readable: $description ($file)"
            return 1
        fi
    else
        if [[ "$required" == "required" ]]; then
            log_check "FAIL" "Required file missing: $description ($file)"
            return 1
        else
            log_check "WARN" "Optional file missing: $description ($file)"
            return 1
        fi
    fi
}

# Function to validate environment variables
check_environment_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [[ -n "$var_value" ]]; then
        if [[ -d "$var_value" ]]; then
            log_check "PASS" "Environment variable set and valid: $var_name=$var_value"
            return 0
        else
            log_check "FAIL" "Environment variable set but directory doesn't exist: $var_name=$var_value"
            return 1
        fi
    else
        log_check "FAIL" "Environment variable not set: $var_name"
        return 1
    fi
}

# Function to test Core Audio compilation
test_core_audio_compilation() {
    log_check "INFO" "Testing Core Audio framework compilation"
    
    local test_dir=$(mktemp -d)
    local test_file="$test_dir/core_audio_test.c"
    local test_binary="$test_dir/core_audio_test"
    
    # Create a minimal Core Audio test program
    cat > "$test_file" << 'TEST_PROGRAM_EOF'
#include <AudioToolbox/AudioToolbox.h>
#include <stdio.h>

int main() {
    printf("Core Audio compilation test successful\n");
    
    // Test basic Core Audio types
    OSStatus status = noErr;
    AudioFileID audioFile = NULL;
    
    if (status == noErr) {
        printf("Core Audio types accessible\n");
        return 0;
    }
    
    return 1;
}
TEST_PROGRAM_EOF
    
    # Attempt compilation
    if clang -framework AudioToolbox -framework Foundation "$test_file" -o "$test_binary" 2>/dev/null; then
        if "$test_binary" >/dev/null 2>&1; then
            log_check "PASS" "Core Audio framework compilation and execution successful"
            rm -rf "$test_dir"
            return 0
        else
            log_check "FAIL" "Core Audio test program compiled but failed to run"
            rm -rf "$test_dir"
            return 1
        fi
    else
        log_check "FAIL" "Core Audio framework compilation failed"
        rm -rf "$test_dir"
        return 1
    fi
}

# =====================================================================
# MAIN VALIDATION SEQUENCE
# =====================================================================

echo "Starting comprehensive Day 1 readiness validation..."
echo

# =====================================================================
# 1. ENVIRONMENT DETECTION AND SOURCING
# =====================================================================

log_check "INFO" "Phase 1: Environment Detection and Sourcing"
echo

# Try to find and source environment file
ENV_FILE=""
ENV_SEARCH_PATHS=(
    "../.core-audio-env"
    "./.core-audio-env"
    "$HOME/Development/CoreAudio/.core-audio-env"
    "../../.core-audio-env"
)

log_check "INFO" "Searching for environment configuration file..."

for env_path in "${ENV_SEARCH_PATHS[@]}"; do
    if [[ -f "$env_path" ]]; then
        ENV_FILE="$env_path"
        log_check "PASS" "Found environment file: $env_path"
        break
    fi
done

if [[ -n "$ENV_FILE" ]]; then
    log_check "INFO" "Sourcing environment file: $ENV_FILE"
    source "$ENV_FILE"
else
    log_check "FAIL" "Environment configuration file not found in any expected location"
    echo "  Expected locations:"
    for path in "${ENV_SEARCH_PATHS[@]}"; do
        echo "    - $path"
    done
fi

echo

# =====================================================================
# 2. SYSTEM PREREQUISITES VALIDATION
# =====================================================================

log_check "INFO" "Phase 2: System Prerequisites Validation"
echo

# Check for required command-line tools
log_check "INFO" "Checking required development tools..."

if command_exists "clang"; then
    CLANG_VERSION=$(clang --version | head -n1)
    log_check "PASS" "Clang compiler available: $CLANG_VERSION"
else
    log_check "FAIL" "Clang compiler not found - install Xcode command line tools"
fi

if command_exists "git"; then
    GIT_VERSION=$(git --version)
    log_check "PASS" "Git version control available: $GIT_VERSION"
else
    log_check "FAIL" "Git not found - required for repository management"
fi

if command_exists "swift"; then
    SWIFT_VERSION=$(swift --version | head -n1)
    log_check "PASS" "Swift compiler available: $SWIFT_VERSION"
else
    log_check "WARN" "Swift compiler not found - some examples may not work"
fi

if command_exists "xcodebuild"; then
    log_check "PASS" "Xcode build tools available"
else
    log_check "WARN" "Xcode build tools not found - may limit some functionality"
fi

# Check for optional but useful tools
if command_exists "cmake"; then
    CMAKE_VERSION=$(cmake --version | head -n1)
    log_check "PASS" "CMake available: $CMAKE_VERSION"
else
    log_check "WARN" "CMake not found - C++ builds may be limited"
fi

echo

# =====================================================================
# 3. CORE AUDIO FRAMEWORK VALIDATION
# =====================================================================

log_check "INFO" "Phase 3: Core Audio Framework Validation"
echo

# Test Core Audio framework access
test_core_audio_compilation

# Check for Core Audio headers
CORE_AUDIO_HEADERS_PATH="/System/Library/Frameworks/AudioToolbox.framework/Headers"
if [[ -d "$CORE_AUDIO_HEADERS_PATH" ]]; then
    log_check "PASS" "Core Audio headers found at: $CORE_AUDIO_HEADERS_PATH"
else
    # Try alternative path
    CORE_AUDIO_HEADERS_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/AudioToolbox.framework/Headers"
    if [[ -d "$CORE_AUDIO_HEADERS_PATH" ]]; then
        log_check "PASS" "Core Audio headers found at: $CORE_AUDIO_HEADERS_PATH"
    else
        log_check "WARN" "Core Audio headers not found in expected locations"
    fi
fi

echo

# =====================================================================
# 4. ENVIRONMENT VARIABLES VALIDATION
# =====================================================================

log_check "INFO" "Phase 4: Environment Variables Validation"
echo

# Check critical environment variables
check_environment_var "CORE_AUDIO_ROOT"
check_environment_var "TUTORIAL_ROOT"
check_environment_var "LOGS_DIR"

# Additional environment context
if [[ -n "$CA_TUTORIAL_BASE" ]]; then
    log_check "PASS" "Tutorial base path set: CA_TUTORIAL_BASE=$CA_TUTORIAL_BASE"
else
    log_check "WARN" "Tutorial base path not set: CA_TUTORIAL_BASE"
fi

echo

# =====================================================================
# 5. DIRECTORY STRUCTURE VALIDATION
# =====================================================================

log_check "INFO" "Phase 5: Directory Structure Validation"
echo

if [[ -n "$CORE_AUDIO_ROOT" && -n "$TUTORIAL_ROOT" ]]; then
    # Core Audio Mastery repository structure
    log_check "INFO" "Validating CoreAudioMastery repository structure..."
    check_directory "$CORE_AUDIO_ROOT" "CoreAudioMastery root"
    check_directory "$CORE_AUDIO_ROOT/Chapters" "Chapters directory"
    check_directory "$CORE_AUDIO_ROOT/Shared" "Shared components directory"
    check_directory "$CORE_AUDIO_ROOT/Integration" "Integration projects directory"
    
    # Tutorial repository structure
    log_check "INFO" "Validating CoreAudioTutorial repository structure..."
    check_directory "$TUTORIAL_ROOT" "CoreAudioTutorial root"
    check_directory "$TUTORIAL_ROOT/daily-sessions" "Daily sessions directory"
    check_directory "$TUTORIAL_ROOT/daily-sessions/day01" "Day 1 session directory"
    check_directory "$TUTORIAL_ROOT/daily-sessions/day02" "Day 2 session directory"
    check_directory "$TUTORIAL_ROOT/scripts" "Build scripts directory"
    check_directory "$TUTORIAL_ROOT/resources" "Resources directory"
    
    # Logs directory
    check_directory "$LOGS_DIR" "Session logs directory"
else
    log_check "FAIL" "Cannot validate directory structure - environment variables not set"
fi

echo

# =====================================================================
# 6. REPOSITORY INITIALIZATION VALIDATION
# =====================================================================

log_check "INFO" "Phase 6: Repository Initialization Validation"
echo

if [[ -n "$CORE_AUDIO_ROOT" ]]; then
    cd "$CORE_AUDIO_ROOT"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        log_check "PASS" "CoreAudioMastery is a git repository"
        
        # Check for initial commit
        if git log --oneline > /dev/null 2>&1; then
            COMMIT_COUNT=$(git rev-list --count HEAD)
            log_check "PASS" "CoreAudioMastery has $COMMIT_COUNT commit(s)"
        else
            log_check "WARN" "CoreAudioMastery git repository has no commits yet"
        fi
    else
        log_check "FAIL" "CoreAudioMastery is not a git repository"
    fi
fi

if [[ -n "$TUTORIAL_ROOT" ]]; then
    cd "$TUTORIAL_ROOT"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        log_check "PASS" "CoreAudioTutorial is a git repository"
        
        # Check for initial commit
        if git log --oneline > /dev/null 2>&1; then
            COMMIT_COUNT=$(git rev-list --count HEAD)
            log_check "PASS" "CoreAudioTutorial has $COMMIT_COUNT commit(s)"
        else
            log_check "WARN" "CoreAudioTutorial git repository has no commits yet"
        fi
    else
        log_check "FAIL" "CoreAudioTutorial is not a git repository"
    fi
fi

echo

# =====================================================================
# 7. TESTING FRAMEWORKS VALIDATION
# =====================================================================

log_check "INFO" "Phase 7: Testing Frameworks Validation"
echo

if [[ -n "$TUTORIAL_ROOT" ]]; then
    # Check Unity framework
    UNITY_PATH="$TUTORIAL_ROOT/shared-frameworks/unity/src"
    check_directory "$UNITY_PATH" "Unity testing framework"
    check_file "$UNITY_PATH/unity.h" "Unity header file" "required"
    check_file "$UNITY_PATH/unity.c" "Unity source file" "required"
    
    # Check GoogleTest framework
    GTEST_PATH="$TUTORIAL_ROOT/shared-frameworks/googletest"
    check_directory "$GTEST_PATH" "GoogleTest framework"
    check_file "$GTEST_PATH/CMakeLists.txt" "GoogleTest CMake configuration" "required"
fi

echo

# =====================================================================
# 8. BUILD SYSTEM VALIDATION
# =====================================================================

log_check "INFO" "Phase 8: Build System Validation"
echo

if [[ -n "$TUTORIAL_ROOT" ]]; then
    # Check environment activation script
    check_file "$TUTORIAL_ROOT/activate-ca-env.sh" "Environment activation script" "required"
    
    # Check build scripts
    check_file "$TUTORIAL_ROOT/scripts/build-c.sh" "C build script" "required"
    
    # Test environment activation
    if [[ -f "$TUTORIAL_ROOT/activate-ca-env.sh" ]]; then
        log_check "INFO" "Testing environment activation script"
        cd "$TUTORIAL_ROOT"
        if source activate-ca-env.sh > /dev/null 2>&1; then
            log_check "PASS" "Environment activation script works"
        else
            log_check "FAIL" "Environment activation script has errors"
        fi
    fi
fi

echo

# =====================================================================
# 9. SESSION LOGGING VALIDATION
# =====================================================================

log_check "INFO" "Phase 9: Session Logging Validation"
echo

if [[ -n "$LOGS_DIR" ]]; then
    # Check for Day 1 session log
    DAY1_LOG="$LOGS_DIR/day01_session.log"
    check_file "$DAY1_LOG" "Day 1 session log" "required"
    
    if [[ -f "$DAY1_LOG" ]]; then
        # Validate log content
        if grep -q "DAY1-START" "$DAY1_LOG" && grep -q "DAY1-COMPLETE" "$DAY1_LOG"; then
            log_check "PASS" "Day 1 session log shows complete workflow"
        else
            log_check "WARN" "Day 1 session log may be incomplete"
        fi
        
        # Show recent log entries
        log_check "INFO" "Recent Day 1 session log entries:"
        tail -5 "$DAY1_LOG" | while read line; do
            echo "    $line"
        done
    fi
fi

echo

# =====================================================================
# 10. FINAL VALIDATION AND RECOMMENDATIONS
# =====================================================================

log_check "INFO" "Phase 10: Final Validation and Recommendations"
echo

# Summary of validation results
echo "======================================================================="
echo "🔍 VALIDATION SUMMARY"
echo "======================================================================="

if [[ "$VALIDATION_PASSED" == true ]]; then
    if [[ ${#WARNINGS_FOUND[@]} -eq 0 ]]; then
        echo "✅ EXCELLENT: Day 1 setup is complete and ready for Day 2!"
        echo "   All systems are properly configured and functional."
    else
        echo "✅ GOOD: Day 1 setup is ready for Day 2 with minor warnings."
        echo "   Core functionality is working, but some optional components have issues."
    fi
else
    echo "❌ ISSUES FOUND: Day 1 setup is not ready for Day 2."
    echo "   Please resolve the following issues before proceeding:"
fi

# Report specific issues
if [[ ${#ISSUES_FOUND[@]} -gt 0 ]]; then
    echo
    echo "🔧 ISSUES TO RESOLVE:"
    for issue in "${ISSUES_FOUND[@]}"; do
        echo "   ❌ $issue"
    done
fi

# Report warnings
if [[ ${#WARNINGS_FOUND[@]} -gt 0 ]]; then
    echo
    echo "⚠️  WARNINGS (optional improvements):"
    for warning in "${WARNINGS_FOUND[@]}"; do
        echo "   ⚠️  $warning"
    done
fi

echo
echo "======================================================================="

if [[ "$VALIDATION_PASSED" == true ]]; then
    echo "🚀 READY FOR DAY 2!"
    echo
    echo "Next Steps:"
    echo "1. Run Day 2 setup scripts:"
    echo "   ./day02_step01_shared_foundation.sh"
    echo "   ./day02_step02_testing_framework.sh"
    echo "   (additional Day 2 steps will be provided)"
    echo
    echo "2. Your Day 1 session log is available at:"
    echo "   $LOGS_DIR/day01_session.log"
    echo
    echo "3. Environment can be activated with:"
    echo "   cd $TUTORIAL_ROOT && source activate-ca-env.sh"
    
    exit 0
else
    echo "🛠️  SETUP INCOMPLETE"
    echo
    echo "Please resolve the issues listed above and run this check again:"
    echo "   ./day01_readiness_check.sh"
    echo
    echo "If you need to re-run Day 1 setup:"
    echo "   ./step01_create_directories.sh"
    echo "   ./step02_initialize_repos.sh"
    echo "   ./step03_setup_environment.sh"
    echo "   ./step04_install_frameworks.sh"
    
    exit 1
fi
