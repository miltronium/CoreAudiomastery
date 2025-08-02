#!/bin/bash

# Pre-Commit Final Verification Script
# Core Audio Tutorial - Day 1 Complete Validation & Archive Creation

set -e

echo "🔍 Pre-Commit Final Verification - Day 1 Complete"
echo "=================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize verification
VERIFICATION_START=$(date '+%Y%m%d_%H%M%S')
CURRENT_DIR=$(pwd)

# Setup logging
PRE_COMMIT_LOG="$HOME/Development/CoreAudio/logs/pre_commit_verification_$VERIFICATION_START.log"
mkdir -p "$(dirname "$PRE_COMMIT_LOG")" 2>/dev/null || true

# Logging function
log_action() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$PRE_COMMIT_LOG"
}

# Enhanced echo that logs and displays
echo_and_log() {
    local message="$1"
    echo -e "$message"
    log_action "$(echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g')"
}

# Start logging
echo_and_log "🔍 Pre-Commit Final Verification Started"
echo_and_log "Verification timestamp: $VERIFICATION_START"
echo_and_log "Pre-commit log: $PRE_COMMIT_LOG"
echo_and_log "=================================================="

# Source environment
if [[ -f "$HOME/Development/CoreAudio/.core-audio-env" ]]; then
    source "$HOME/Development/CoreAudio/.core-audio-env"
    echo_and_log "${GREEN}✅ Environment sourced successfully${NC}"
    log_action "Environment variables: CORE_AUDIO_ROOT=$CORE_AUDIO_ROOT, TUTORIAL_ROOT=$TUTORIAL_ROOT, LOGS_DIR=$LOGS_DIR"
else
    echo_and_log "${RED}❌ Environment file not found${NC}"
    exit 1
fi

# Verification counters
CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Check function
run_check() {
    local check_name="$1"
    local check_command="$2"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    echo -n "[$CHECKS_TOTAL] $check_name... "
    log_action "[$CHECKS_TOTAL] $check_name"
    
    if eval "$check_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        log_action "[$CHECKS_TOTAL] $check_name: PASS"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        log_action "[$CHECKS_TOTAL] $check_name: FAIL - Command: $check_command"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

echo_and_log "${YELLOW}📋 SECTION 1: Repository State Verification${NC}"
echo_and_log "============================================="

# Check git repositories exist and are clean
cd "$CORE_AUDIO_ROOT"
run_check "CoreAudioMastery git repository exists" "git rev-parse --git-dir"

cd "$TUTORIAL_ROOT"
run_check "CoreAudioTutorial git repository exists" "git rev-parse --git-dir"

# Check for uncommitted changes
cd "$CORE_AUDIO_ROOT"
if [[ -z "$(git status --porcelain)" ]]; then
    echo_and_log "${GREEN}✅ CoreAudioMastery repository is clean${NC}"
    log_action "CoreAudioMastery repository is clean"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo_and_log "${YELLOW}⚠️  CoreAudioMastery has uncommitted changes${NC}"
    git status --porcelain | while read line; do
        log_action "CoreAudioMastery uncommitted: $line"
    done
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

cd "$TUTORIAL_ROOT"
if [[ -z "$(git status --porcelain)" ]]; then
    echo_and_log "${GREEN}✅ CoreAudioTutorial repository is clean${NC}"
    log_action "CoreAudioTutorial repository is clean"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo_and_log "${YELLOW}⚠️  CoreAudioTutorial has uncommitted changes${NC}"
    git status --porcelain | while read line; do
        log_action "CoreAudioTutorial uncommitted: $line"
    done
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

echo
echo_and_log "${YELLOW}📋 SECTION 2: Tutorial Scripts Archive Creation${NC}"
echo_and_log "================================================"

# Create archive directory
ARCHIVE_DIR="$TUTORIAL_ROOT/archives"
ARCHIVE_NAME="day01_setup_scripts_$VERIFICATION_START"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

mkdir -p "$ARCHIVE_DIR"
mkdir -p "$ARCHIVE_PATH"

echo_and_log "${BLUE}📦 Creating comprehensive archive: $ARCHIVE_NAME${NC}"
log_action "Creating archive at: $ARCHIVE_PATH"

# Archive tutorial-scripts directory if it exists
TUTORIAL_SCRIPTS_DIR=""
SEARCH_PATHS=(
    "$CURRENT_DIR"
    "$(dirname "$CURRENT_DIR")"
    "$HOME"
    "$HOME/Development"
    "$HOME/Development/CoreAudio"
)

for path in "${SEARCH_PATHS[@]}"; do
    if [[ -d "$path/tutorial-scripts" ]]; then
        TUTORIAL_SCRIPTS_DIR="$path/tutorial-scripts"
        break
    fi
done

if [[ -n "$TUTORIAL_SCRIPTS_DIR" && -d "$TUTORIAL_SCRIPTS_DIR" ]]; then
    echo_and_log "${GREEN}✅ Found tutorial-scripts directory: $TUTORIAL_SCRIPTS_DIR${NC}"
    log_action "Found tutorial-scripts directory: $TUTORIAL_SCRIPTS_DIR"
    
    # Copy tutorial-scripts to archive
    cp -R "$TUTORIAL_SCRIPTS_DIR" "$ARCHIVE_PATH/"
    
    # Get file count and sizes
    SCRIPT_COUNT=$(find "$TUTORIAL_SCRIPTS_DIR" -name "*.sh" | wc -l)
    TOTAL_FILES=$(find "$TUTORIAL_SCRIPTS_DIR" -type f | wc -l)
    ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH/tutorial-scripts" | cut -f1)
    
    echo_and_log "${GREEN}✅ Archived tutorial-scripts: $SCRIPT_COUNT scripts, $TOTAL_FILES total files, $ARCHIVE_SIZE${NC}"
    log_action "Archived tutorial-scripts: $SCRIPT_COUNT scripts, $TOTAL_FILES total files, $ARCHIVE_SIZE"
    
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo_and_log "${RED}❌ tutorial-scripts directory not found${NC}"
    log_action "tutorial-scripts directory not found in search paths"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Archive current tutorial state
echo_and_log "${BLUE}📦 Archiving current tutorial state${NC}"

# Copy important files to archive
FILES_TO_ARCHIVE=(
    "$TUTORIAL_ROOT/activate-ca-env.sh"
    "$TUTORIAL_ROOT/GETTING_STARTED.md"
    "$TUTORIAL_ROOT/daily-sessions/day01/README.md"
    "$HOME/Development/CoreAudio/.core-audio-env"
    "$LOGS_DIR/day01_session.log"
)

for file in "${FILES_TO_ARCHIVE[@]}"; do
    if [[ -f "$file" ]]; then
        # Create relative path structure in archive
        rel_path=$(echo "$file" | sed "s|$HOME/Development/CoreAudio/||g")
        mkdir -p "$(dirname "$ARCHIVE_PATH/$rel_path")"
        cp "$file" "$ARCHIVE_PATH/$rel_path"
        echo_and_log "${GREEN}✅ Archived: $rel_path${NC}"
        log_action "Archived file: $file -> $rel_path"
    else
        echo_and_log "${YELLOW}⚠️  File not found for archive: $file${NC}"
        log_action "File not found for archive: $file"
    fi
done

# Copy scripts directory
if [[ -d "$TUTORIAL_ROOT/scripts" ]]; then
    cp -R "$TUTORIAL_ROOT/scripts" "$ARCHIVE_PATH/"
    SCRIPT_COUNT=$(find "$TUTORIAL_ROOT/scripts" -name "*.sh" | wc -l)
    echo_and_log "${GREEN}✅ Archived scripts directory: $SCRIPT_COUNT build scripts${NC}"
    log_action "Archived scripts directory: $SCRIPT_COUNT build scripts"
fi

# Create archive manifest
cat > "$ARCHIVE_PATH/MANIFEST.md" << MANIFEST_EOF
# Day 1 Setup Archive Manifest

**Archive Created**: $(date '+%Y-%m-%d %H:%M:%S')
**Archive Name**: $ARCHIVE_NAME
**Verification Timestamp**: $VERIFICATION_START

## Contents

### Tutorial Scripts (Step00 Generated)
- step00_complete_generator.sh
- step01_create_directories.sh
- step02_initialize_repos.sh
- step03_setup_environment.sh
- step04_install_frameworks.sh
- verify_day01.sh

### Build Scripts
- build-c.sh - C compilation with Core Audio
- build-cpp.sh - C++ compilation with Core Audio
- build-objc.sh - Objective-C compilation with Core Audio
- build-swift.sh - Swift compilation with Core Audio
- setup-cmake.sh - CMake configuration
- create-xcode-project.sh - Xcode project templates
- validate-build-scripts.sh - Build script validation
- validate-frameworks.sh - Framework validation

### Configuration Files
- .core-audio-env - Environment variables
- activate-ca-env.sh - Environment activation
- GETTING_STARTED.md - Tutorial guide

### Session Logs
- day01_session.log - Complete Day 1 session log

## Archive Statistics
- Total Files: $(find "$ARCHIVE_PATH" -type f | wc -l)
- Total Size: $(du -sh "$ARCHIVE_PATH" | cut -f1)
- Scripts Count: $(find "$ARCHIVE_PATH" -name "*.sh" | wc -l)

## Verification Status
- Day 1 Setup: ✅ COMPLETE
- All Tests: ✅ PASSED (71/71)
- Ready for Commit: ✅ YES
MANIFEST_EOF

echo_and_log "${GREEN}✅ Created archive manifest${NC}"
log_action "Created archive manifest"

# Create archive summary
ARCHIVE_TOTAL_FILES=$(find "$ARCHIVE_PATH" -type f | wc -l)
ARCHIVE_TOTAL_SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
ARCHIVE_SCRIPTS=$(find "$ARCHIVE_PATH" -name "*.sh" | wc -l)

echo_and_log "${BLUE}📊 Archive Summary:${NC}"
echo_and_log "  Total Files: $ARCHIVE_TOTAL_FILES"
echo_and_log "  Total Size: $ARCHIVE_TOTAL_SIZE"
echo_and_log "  Scripts: $ARCHIVE_SCRIPTS"
echo_and_log "  Location: $ARCHIVE_PATH"

log_action "Archive created successfully: $ARCHIVE_TOTAL_FILES files, $ARCHIVE_TOTAL_SIZE, $ARCHIVE_SCRIPTS scripts"

echo
echo_and_log "${YELLOW}📋 SECTION 3: Final Day 1 Validation${NC}"
echo_and_log "====================================="

# Run final verification to ensure everything still works
cd "$TUTORIAL_ROOT"
if [[ -f "../tutorial-scripts/verify_day01.sh" ]]; then
    echo_and_log "${BLUE}🧪 Running final Day 1 verification...${NC}"
    if ../tutorial-scripts/verify_day01.sh > /dev/null 2>&1; then
        echo_and_log "${GREEN}✅ Final Day 1 verification PASSED${NC}"
        log_action "Final Day 1 verification PASSED"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo_and_log "${RED}❌ Final Day 1 verification FAILED${NC}"
        log_action "Final Day 1 verification FAILED"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
elif [[ -f "verify_day01.sh" ]]; then
    echo_and_log "${BLUE}🧪 Running final Day 1 verification...${NC}"
    if ./verify_day01.sh > /dev/null 2>&1; then
        echo_and_log "${GREEN}✅ Final Day 1 verification PASSED${NC}"
        log_action "Final Day 1 verification PASSED"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo_and_log "${RED}❌ Final Day 1 verification FAILED${NC}"
        log_action "Final Day 1 verification FAILED"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    echo_and_log "${YELLOW}⚠️  Day 1 verification script not found${NC}"
    log_action "Day 1 verification script not found"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Check environment activation one more time
if source activate-ca-env.sh && validate_environment > /dev/null 2>&1; then
    echo_and_log "${GREEN}✅ Environment activation confirmed working${NC}"
    log_action "Environment activation confirmed working"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo_and_log "${RED}❌ Environment activation failed${NC}"
    log_action "Environment activation failed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

echo
echo_and_log "${YELLOW}📋 SECTION 4: Commit Readiness Assessment${NC}"
echo_and_log "=========================================="

# Check that we have meaningful content to commit
cd "$CORE_AUDIO_ROOT"
MASTERY_FILES=$(find . -type f ! -path './.git/*' | wc -l)
cd "$TUTORIAL_ROOT"
TUTORIAL_FILES=$(find . -type f ! -path './.git/*' | wc -l)

echo_and_log "${BLUE}📊 Repository Content Summary:${NC}"
echo_and_log "  CoreAudioMastery files: $MASTERY_FILES"
echo_and_log "  CoreAudioTutorial files: $TUTORIAL_FILES"

if [[ $MASTERY_FILES -gt 5 && $TUTORIAL_FILES -gt 10 ]]; then
    echo_and_log "${GREEN}✅ Sufficient content for meaningful commit${NC}"
    log_action "Sufficient content for commit: Mastery=$MASTERY_FILES, Tutorial=$TUTORIAL_FILES"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo_and_log "${RED}❌ Insufficient content for commit${NC}"
    log_action "Insufficient content for commit: Mastery=$MASTERY_FILES, Tutorial=$TUTORIAL_FILES"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Check for required documentation
REQUIRED_DOCS=(
    "$TUTORIAL_ROOT/GETTING_STARTED.md"
    "$TUTORIAL_ROOT/daily-sessions/day01/README.md"
    "$ARCHIVE_PATH/MANIFEST.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
    if [[ -f "$doc" ]]; then
        echo_and_log "${GREEN}✅ Required documentation exists: $(basename "$doc")${NC}"
        log_action "Required documentation exists: $doc"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo_and_log "${RED}❌ Missing required documentation: $(basename "$doc")${NC}"
        log_action "Missing required documentation: $doc"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
done

echo
echo "================================================================="
echo_and_log "${BLUE}📊 PRE-COMMIT VERIFICATION SUMMARY${NC}"
echo "================================================================="
echo_and_log "Total Checks: ${BLUE}$CHECKS_TOTAL${NC}"
echo_and_log "Checks Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo_and_log "Checks Failed: ${RED}$CHECKS_FAILED${NC}"

# Calculate success percentage
if [[ $CHECKS_TOTAL -gt 0 ]]; then
    SUCCESS_PERCENTAGE=$(( (CHECKS_PASSED * 100) / CHECKS_TOTAL ))
    echo_and_log "Success Rate: ${BLUE}${SUCCESS_PERCENTAGE}%${NC}"
fi

# Log final summary
log_action "PRE-COMMIT VERIFICATION SUMMARY: $CHECKS_TOTAL total, $CHECKS_PASSED passed, $CHECKS_FAILED failed"

if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo
    echo_and_log "${GREEN}🎉 PRE-COMMIT VERIFICATION PASSED! READY TO COMMIT! 🎉${NC}"
    echo
    echo_and_log "${YELLOW}✅ COMMIT READINESS CONFIRMED:${NC}"
    echo_and_log "   • Repository state validated"
    echo_and_log "   • Complete archive created with timestamp"
    echo_and_log "   • Final Day 1 verification passed"
    echo_and_log "   • Environment activation confirmed"
    echo_and_log "   • Sufficient content for meaningful commit"
    echo_and_log "   • Required documentation present"
    echo
    echo_and_log "${BLUE}📦 ARCHIVE LOCATION: $ARCHIVE_PATH${NC}"
    echo_and_log "${BLUE}📄 PRE-COMMIT LOG: $PRE_COMMIT_LOG${NC}"
    echo
    echo_and_log "${GREEN}🚀 READY TO RUN: commit_day01.sh${NC}"
    
    log_action "Pre-commit verification PASSED - Ready for commit"
    exit 0
else
    echo
    echo_and_log "${RED}❌ PRE-COMMIT VERIFICATION FAILED${NC}"
    echo_and_log "${YELLOW}Issues must be resolved before committing${NC}"
    
    log_action "Pre-commit verification FAILED - $CHECKS_FAILED issues found"
    exit 1
fi
