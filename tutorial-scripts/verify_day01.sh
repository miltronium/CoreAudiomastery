#!/bin/bash

# Complete Day 1 Verification Script with Comprehensive Logging
# Core Audio Tutorial - Day 1 Final Validation

set -e

echo "🧪 Day 1 Setup Verification - Comprehensive Test Suite"
echo "======================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Setup logging
VERIFICATION_LOG="$HOME/Development/CoreAudio/logs/day01_verification_$(date '+%Y%m%d_%H%M%S').log"
mkdir -p "$(dirname "$VERIFICATION_LOG")" 2>/dev/null || true

# Logging function
log_action() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$VERIFICATION_LOG"
}

# Enhanced echo that logs and displays
echo_and_log() {
    local message="$1"
    echo -e "$message"
    log_action "$(echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g')"  # Strip color codes for log
}

# Start logging
echo_and_log "🧪 Day 1 Setup Verification Started"
echo_and_log "Verification log: $VERIFICATION_LOG"
echo_and_log "======================================================"

# Counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function with logging
run_test() {
    local test_name="$1"
    local test_command="$2"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo -n "[$TESTS_TOTAL] Testing $test_name... "
    log_action "[$TESTS_TOTAL] Testing $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        log_action "[$TESTS_TOTAL] $test_name: PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        log_action "[$TESTS_TOTAL] $test_name: FAIL - Command: $test_command"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test function with output and logging
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo_and_log "${BLUE}[$TESTS_TOTAL] Testing $test_name...${NC}"
    
    if eval "$test_command"; then
        echo_and_log "${GREEN}✅ PASS${NC}"
        log_action "[$TESTS_TOTAL] $test_name: PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo_and_log "${RED}❌ FAIL${NC}"
        log_action "[$TESTS_TOTAL] $test_name: FAIL - Command: $test_command"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo_and_log "${YELLOW}📋 PHASE 1: Directory Structure Validation${NC}"
echo_and_log "============================================"

# Test directory structure
run_test "Base directory exists" "[[ -d '$HOME/Development/CoreAudio' ]]"
run_test "CoreAudioMastery exists" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery' ]]"
run_test "CoreAudioTutorial exists" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial' ]]"
run_test "Logs directory exists" "[[ -d '$HOME/Development/CoreAudio/logs' ]]"
run_test "Environment file exists" "[[ -f '$HOME/Development/CoreAudio/.core-audio-env' ]]"

# Test CoreAudioMastery structure
run_test "Chapters directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery/Chapters' ]]"
run_test "Shared directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery/Shared' ]]"
run_test "Integration directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery/Integration' ]]"
run_test "Prompts directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery/Prompts' ]]"
run_test "Setup directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioMastery/setup' ]]"

# Test CoreAudioTutorial structure
run_test "Daily sessions directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/daily-sessions' ]]"
run_test "Day 1 session directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/daily-sessions/day01' ]]"
run_test "Day 2 session directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/daily-sessions/day02' ]]"
run_test "Documentation directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/documentation' ]]"
run_test "Resources directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/resources' ]]"
run_test "Scripts directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/scripts' ]]"
run_test "Shared frameworks directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks' ]]"
run_test "Validation directory" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/validation' ]]"

echo
echo_and_log "${YELLOW}📋 PHASE 2: Environment Variables Validation${NC}"
echo_and_log "=============================================="

# Source environment and test
if [[ -f "$HOME/Development/CoreAudio/.core-audio-env" ]]; then
    source "$HOME/Development/CoreAudio/.core-audio-env"
    log_action "Environment file sourced successfully"
    
    run_test "CORE_AUDIO_ROOT set" "[[ -n '$CORE_AUDIO_ROOT' ]]"
    run_test "TUTORIAL_ROOT set" "[[ -n '$TUTORIAL_ROOT' ]]"
    run_test "LOGS_DIR set" "[[ -n '$LOGS_DIR' ]]"
    run_test "CA_TUTORIAL_BASE set" "[[ -n '$CA_TUTORIAL_BASE' ]]"
    run_test "CORE_AUDIO_ROOT points to correct dir" "[[ '$CORE_AUDIO_ROOT' == '$HOME/Development/CoreAudio/CoreAudioMastery' ]]"
    run_test "TUTORIAL_ROOT points to correct dir" "[[ '$TUTORIAL_ROOT' == '$HOME/Development/CoreAudio/CoreAudioTutorial' ]]"
    run_test "LOGS_DIR points to correct dir" "[[ '$LOGS_DIR' == '$HOME/Development/CoreAudio/logs' ]]"
    
    log_action "Environment variables: CORE_AUDIO_ROOT=$CORE_AUDIO_ROOT, TUTORIAL_ROOT=$TUTORIAL_ROOT, LOGS_DIR=$LOGS_DIR, CA_TUTORIAL_BASE=$CA_TUTORIAL_BASE"
else
    echo_and_log "${RED}❌ Environment file not found${NC}"
    log_action "Environment file not found at: $HOME/Development/CoreAudio/.core-audio-env"
    TESTS_TOTAL=$((TESTS_TOTAL + 7))
    TESTS_FAILED=$((TESTS_FAILED + 7))
fi

echo
echo_and_log "${YELLOW}📋 PHASE 3: Git Repository Validation${NC}"
echo_and_log "======================================"

run_test "CoreAudioMastery git initialized" "cd '$HOME/Development/CoreAudio/CoreAudioMastery' && git rev-parse --git-dir"
run_test "CoreAudioTutorial git initialized" "cd '$HOME/Development/CoreAudio/CoreAudioTutorial' && git rev-parse --git-dir"

# Check git status and log additional info
if [[ -d "$HOME/Development/CoreAudio/CoreAudioMastery/.git" ]]; then
    cd "$HOME/Development/CoreAudio/CoreAudioMastery"
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "error")
    if [[ "$GIT_STATUS" == "error" ]]; then
        log_action "CoreAudioMastery git status check failed"
    elif [[ -z "$GIT_STATUS" ]]; then
        log_action "CoreAudioMastery repository is clean"
    else
        log_action "CoreAudioMastery has uncommitted changes: $(echo "$GIT_STATUS" | wc -l) files"
    fi
fi

if [[ -d "$HOME/Development/CoreAudio/CoreAudioTutorial/.git" ]]; then
    cd "$HOME/Development/CoreAudio/CoreAudioTutorial"
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "error")
    if [[ "$GIT_STATUS" == "error" ]]; then
        log_action "CoreAudioTutorial git status check failed"
    elif [[ -z "$GIT_STATUS" ]]; then
        log_action "CoreAudioTutorial repository is clean"
    else
        log_action "CoreAudioTutorial has uncommitted changes: $(echo "$GIT_STATUS" | wc -l) files"
    fi
fi

echo
echo_and_log "${YELLOW}📋 PHASE 4: Environment Tools Validation${NC}"
echo_and_log "========================================"

run_test "Xcode command line tools (clang)" "command -v clang"
run_test "Git available" "command -v git"
run_test "Curl available" "command -v curl"
run_test "Swift compiler available" "command -v swiftc"

echo
echo_and_log "${YELLOW}📋 PHASE 5: Core Audio Framework Validation${NC}"
echo_and_log "============================================="

# Test Core Audio compilation
TEST_CA_FILE="/tmp/test_ca_$.c"
TEST_CA_BINARY="/tmp/test_ca_$"

cat > "$TEST_CA_FILE" << 'TEST_CA_EOF'
#include <AudioToolbox/AudioToolbox.h>
#include <stdio.h>

int main() {
    AudioFileID audioFile;
    OSStatus status = noErr;
    UInt32 propertySize = 0;
    
    printf("Core Audio framework test successful\n");
    printf("AudioFileID size: %lu bytes\n", sizeof(audioFile));
    printf("OSStatus noErr value: %d\n", status);
    printf("kAudioFileReadPermission: %d\n", kAudioFileReadPermission);
    
    return 0;
}
TEST_CA_EOF

log_action "Created Core Audio test file: $TEST_CA_FILE"

# Test compilation step by step for better debugging
echo -n "[$(($TESTS_TOTAL + 1))] Testing Core Audio framework compilation... "
log_action "[$(($TESTS_TOTAL + 1))] Testing Core Audio framework compilation"

# First, let's check if the test file was created properly
if [[ ! -f "$TEST_CA_FILE" ]]; then
    echo -e "${RED}❌ FAIL (test file not created)${NC}"
    log_action "[$(($TESTS_TOTAL + 1))] Core Audio framework compilation: FAIL - test file not created"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 2))  # Skip both compilation and execution
    echo -n "[$(($TESTS_TOTAL))] Testing Core Audio framework execution... "
    echo -e "${RED}❌ SKIP (no test file)${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    # Capture compilation output with a more robust approach
    COMPILE_CMD="clang -framework AudioToolbox \"$TEST_CA_FILE\" -o \"$TEST_CA_BINARY\""
    log_action "Compilation command: $COMPILE_CMD"
    
    # Use a simpler, more reliable compilation test
    if clang -framework AudioToolbox "$TEST_CA_FILE" -o "$TEST_CA_BINARY" 2>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}"
        log_action "[$(($TESTS_TOTAL + 1))] Core Audio framework compilation: PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Test execution
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
        echo -n "[$(($TESTS_TOTAL))] Testing Core Audio framework execution... "
        log_action "[$(($TESTS_TOTAL))] Testing Core Audio framework execution"
        
        if [[ -f "$TEST_CA_BINARY" ]] && "$TEST_CA_BINARY" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PASS${NC}"
            log_action "[$(($TESTS_TOTAL))] Core Audio framework execution: PASS"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAIL${NC}"
            log_action "[$(($TESTS_TOTAL))] Core Audio framework execution: FAIL"
            if [[ ! -f "$TEST_CA_BINARY" ]]; then
                log_action "Binary file was not created: $TEST_CA_BINARY"
            fi
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "${RED}❌ FAIL${NC}"
        log_action "[$(($TESTS_TOTAL + 1))] Core Audio framework compilation: FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        
        # Capture and log the actual error for debugging
        COMPILE_ERROR=$(clang -framework AudioToolbox "$TEST_CA_FILE" -o "$TEST_CA_BINARY" 2>&1)
        log_action "Compilation error output: $COMPILE_ERROR"
        
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
        echo -n "[$(($TESTS_TOTAL))] Testing Core Audio framework execution... "
        echo -e "${RED}❌ SKIP (compilation failed)${NC}"
        log_action "[$(($TESTS_TOTAL))] Core Audio framework execution: SKIP (compilation failed)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Cleanup
rm -f "$TEST_CA_FILE" "$TEST_CA_BINARY"
log_action "Cleaned up Core Audio test files"

echo
echo_and_log "${YELLOW}📋 PHASE 6: Environment Activation Validation${NC}"
echo_and_log "=============================================="

run_test "Environment activation script exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/activate-ca-env.sh' ]]"
run_test "Environment activation script executable" "[[ -x '$HOME/Development/CoreAudio/CoreAudioTutorial/activate-ca-env.sh' ]]"

# Test environment activation functionality
cd "$HOME/Development/CoreAudio/CoreAudioTutorial"
if [[ -f "activate-ca-env.sh" ]]; then
    if source activate-ca-env.sh && command -v validate_environment > /dev/null && validate_environment > /dev/null 2>&1; then
        echo_and_log "${GREEN}✅ Environment activation test PASSED${NC}"
        log_action "Environment activation test PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo_and_log "${RED}❌ Environment activation test FAILED${NC}"
        log_action "Environment activation test FAILED"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo
echo_and_log "${YELLOW}📋 PHASE 7: Build Scripts Comprehensive Validation${NC}"
echo_and_log "=================================================="

# Check all expected build scripts
declare -a BUILD_SCRIPTS=(
    "build-c.sh"
    "build-cpp.sh"
    "build-objc.sh"
    "build-swift.sh"
    "setup-cmake.sh"
    "create-xcode-project.sh"
    "validate-build-scripts.sh"
    "validate-frameworks.sh"
)

for script in "${BUILD_SCRIPTS[@]}"; do
    script_path="$HOME/Development/CoreAudio/CoreAudioTutorial/scripts/$script"
    run_test "$script exists" "[[ -f '$script_path' ]]"
    run_test "$script executable" "[[ -x '$script_path' ]]"
    
    # Check for Core Audio framework reference in appropriate scripts
    case "$script" in
        build-*.sh)
            if [[ -f "$script_path" ]] && grep -q "AudioToolbox" "$script_path"; then
                echo_and_log "${GREEN}✅ $script contains AudioToolbox framework${NC}"
                log_action "$script contains AudioToolbox framework reference"
            else
                echo_and_log "${YELLOW}⚠️  $script missing AudioToolbox framework${NC}"
                log_action "$script missing AudioToolbox framework reference"
            fi
            ;;
    esac
done

# Test build scripts validation functionality
if [[ -f "$HOME/Development/CoreAudio/CoreAudioTutorial/scripts/validate-build-scripts.sh" ]]; then
    cd "$HOME/Development/CoreAudio/CoreAudioTutorial"
    run_test "Build scripts validation functionality" "scripts/validate-build-scripts.sh"
fi

echo
echo_and_log "${YELLOW}📋 PHASE 8: Testing Frameworks Validation${NC}"
echo_and_log "========================================="

# Unity framework comprehensive check
run_test "Unity header exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/unity/src/unity.h' ]]"
run_test "Unity source exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/unity/src/unity.c' ]]"
run_test "Unity internals exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/unity/src/unity_internals.h' ]]"

# GoogleTest framework comprehensive check
run_test "GoogleTest directory exists" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/googletest' ]]"
run_test "GoogleTest CMakeLists exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/googletest/CMakeLists.txt' ]]"
run_test "GoogleTest include directory exists" "[[ -d '$HOME/Development/CoreAudio/CoreAudioTutorial/shared-frameworks/googletest/googletest/include' ]]"

# Test frameworks validation script
run_test "Framework validation script exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/scripts/validate-frameworks.sh' ]]"

if [[ -f "$HOME/Development/CoreAudio/CoreAudioTutorial/scripts/validate-frameworks.sh" ]]; then
    cd "$HOME/Development/CoreAudio/CoreAudioTutorial"
    run_test "Framework validation functionality" "scripts/validate-frameworks.sh"
fi

echo
echo_and_log "${YELLOW}📋 PHASE 9: Session Logging Validation${NC}"
echo_and_log "====================================="

run_test "Day 1 session log exists" "[[ -f '$HOME/Development/CoreAudio/logs/day01_session.log' ]]"

if [[ -f "$HOME/Development/CoreAudio/logs/day01_session.log" ]]; then
    LOG_ENTRIES=$(wc -l < "$HOME/Development/CoreAudio/logs/day01_session.log")
    LOG_SIZE=$(ls -lh "$HOME/Development/CoreAudio/logs/day01_session.log" | awk '{print $5}')
    
    echo_and_log "${BLUE}📄 Day 1 Session Log Summary:${NC}"
    echo_and_log "Total log entries: $LOG_ENTRIES"
    echo_and_log "Log size: $LOG_SIZE"
    
    log_action "Day 1 session log analysis: $LOG_ENTRIES entries, $LOG_SIZE size"
    
    # Check for key step markers
    declare -a LOG_MARKERS=(
        "DAY1-STEP1"
        "DAY1-STEP2"
        "DAY1-STEP3"
        "DAY1-STEP4"
        "DAY1-COMPLETE"
    )
    
    for marker in "${LOG_MARKERS[@]}"; do
        if grep -q "$marker" "$HOME/Development/CoreAudio/logs/day01_session.log"; then
            echo_and_log "${GREEN}✅ $marker found in session log${NC}"
            log_action "$marker found in session log"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo_and_log "${RED}❌ $marker missing from session log${NC}"
            log_action "$marker missing from session log"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    done
fi

echo
echo_and_log "${YELLOW}📋 PHASE 10: Documentation Validation${NC}"
echo_and_log "====================================="

run_test "GETTING_STARTED.md exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/GETTING_STARTED.md' ]]"
run_test "Day 1 README.md exists" "[[ -f '$HOME/Development/CoreAudio/CoreAudioTutorial/daily-sessions/day01/README.md' ]]"

# Check documentation content
if [[ -f "$HOME/Development/CoreAudio/CoreAudioTutorial/GETTING_STARTED.md" ]]; then
    if grep -q "Core Audio Tutorial" "$HOME/Development/CoreAudio/CoreAudioTutorial/GETTING_STARTED.md"; then
        echo_and_log "${GREEN}✅ GETTING_STARTED.md contains expected content${NC}"
        log_action "GETTING_STARTED.md contains expected content"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo_and_log "${RED}❌ GETTING_STARTED.md missing expected content${NC}"
        log_action "GETTING_STARTED.md missing expected content"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo
echo_and_log "${YELLOW}📋 PHASE 11: Integration Test${NC}"
echo_and_log "=========================="

# Comprehensive integration test
INTEGRATION_TEST_DIR="/tmp/ca_integration_test_$$"
mkdir -p "$INTEGRATION_TEST_DIR"
log_action "Created integration test directory: $INTEGRATION_TEST_DIR"

cat > "$INTEGRATION_TEST_DIR/test.c" << 'INTEGRATION_TEST_EOF'
#include <AudioToolbox/AudioToolbox.h>
#include <stdio.h>

int main() {
    printf("=== Core Audio Integration Test ===\n");
    
    // Test basic Core Audio types
    AudioFileID audioFile;
    OSStatus status = noErr;
    UInt32 propertySize = 0;
    
    printf("AudioFileID size: %lu bytes\n", sizeof(audioFile));
    printf("OSStatus success value: %d\n", status);
    printf("UInt32 size: %lu bytes\n", sizeof(propertySize));
    
    // Test property constants
    printf("kAudioFileReadPermission: %d\n", kAudioFileReadPermission);
    printf("kAudioFilePropertyInfoDictionary: %d\n", kAudioFilePropertyInfoDictionary);
    
    // Test some additional Core Audio types and constants
    AudioStreamBasicDescription asbd;
    printf("AudioStreamBasicDescription size: %lu bytes\n", sizeof(asbd));
    
    // Test error codes
    printf("noErr constant: %d\n", noErr);
    printf("kAudioFileUnsupportedFileTypeError: %d\n", kAudioFileUnsupportedFileTypeError);
    
    printf("✅ Integration test successful!\n");
    return 0;
}
INTEGRATION_TEST_EOF

log_action "Created integration test source file"

cd "$INTEGRATION_TEST_DIR"
if clang -framework AudioToolbox test.c -o integration_test && ./integration_test; then
    echo_and_log "${GREEN}✅ Integration test PASSED${NC}"
    log_action "Integration test PASSED"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo_and_log "${RED}❌ Integration test FAILED${NC}"
    log_action "Integration test FAILED"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Cleanup
rm -rf "$INTEGRATION_TEST_DIR"
log_action "Cleaned up integration test directory"

echo
echo "================================================================="
echo_and_log "${BLUE}📊 VERIFICATION SUMMARY${NC}"
echo "================================================================="
echo_and_log "Total Tests Run: ${BLUE}$TESTS_TOTAL${NC}"
echo_and_log "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo_and_log "Tests Failed: ${RED}$TESTS_FAILED${NC}"

# Calculate success percentage
if [[ $TESTS_TOTAL -gt 0 ]]; then
    SUCCESS_PERCENTAGE=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
    echo_and_log "Success Rate: ${BLUE}${SUCCESS_PERCENTAGE}%${NC}"
    log_action "Success rate: ${SUCCESS_PERCENTAGE}% ($TESTS_PASSED/$TESTS_TOTAL)"
fi

# Log final summary
log_action "VERIFICATION SUMMARY: $TESTS_TOTAL total, $TESTS_PASSED passed, $TESTS_FAILED failed"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo
    echo_and_log "${GREEN}🎉 ALL TESTS PASSED! Day 1 Setup Complete! 🎉${NC}"
    echo
    echo_and_log "${YELLOW}✅ SUCCESS CRITERIA MET:${NC}"
    echo_and_log "   • Complete directory structure created and validated"
    echo_and_log "   • Environment variables properly configured and tested"
    echo_and_log "   • Git repositories initialized and accessible"
    echo_and_log "   • Core Audio framework compilation and execution verified"
    echo_and_log "   • Build scripts operational (8 scripts verified)"
    echo_and_log "   • Testing frameworks installed (Unity & GoogleTest)"
    echo_and_log "   • Session logging active with all step markers"
    echo_and_log "   • Environment activation working correctly"
    echo_and_log "   • Documentation created and validated"
    echo_and_log "   • Integration test passed successfully"
    echo
    echo_and_log "${BLUE}🚀 READY FOR: Day 2 Foundation Building${NC}"
    echo_and_log "${BLUE}📍 TUTORIAL ROOT: $HOME/Development/CoreAudio/CoreAudioTutorial${NC}"
    echo_and_log "${BLUE}📍 STUDY GUIDE ROOT: $HOME/Development/CoreAudio/CoreAudioMastery${NC}"
    
    log_action "Day 1 verification COMPLETED SUCCESSFULLY - Ready for commits and Day 2"
    echo_and_log "📄 Complete verification log saved to: $VERIFICATION_LOG"
    
    exit 0
else
    echo
    echo_and_log "${RED}❌ SOME TESTS FAILED - Setup Incomplete${NC}"
    echo_and_log "${YELLOW}Please review failed tests and re-run setup steps as needed${NC}"
    echo_and_log "${YELLOW}Consider running step00 generator again to ensure complete setup${NC}"
    
    log_action "Day 1 verification FAILED - $TESTS_FAILED tests failed"
    echo_and_log "📄 Detailed failure log saved to: $VERIFICATION_LOG"
    
    exit 1
fi
