#!/bin/bash

# Pre-Flight Check Script for Remote Repository Setup
# Validates all prerequisites before running remote_repo_setup.sh
# Run this from: ~/Development/CoreAudio/CoreAudioTutorial/tutorial-scripts/

set -e

# =====================================================================
# CONFIGURATION & LOGGING SETUP
# =====================================================================

SCRIPT_VERSION="1.0.0"
CHECK_NAME="Pre-Flight Check for Remote Repository Setup"
EXECUTION_ID="preflight_$(date '+%Y%m%d_%H%M%S')"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Find base directory
find_base_directory() {
    local current_dir="$(pwd)"
    local search_paths=(
        "$current_dir"
        "$(dirname "$current_dir")"
        "$HOME/Development/CoreAudio"
        "../.."
        "../../.."
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path/.core-audio-env" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    echo "$HOME/Development/CoreAudio"  # fallback
}

BASE_DIR="$(find_base_directory)"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"

# Log files
PREFLIGHT_LOG="$LOG_DIR/preflight_${EXECUTION_ID}.log"
PREFLIGHT_REPORT="$LOG_DIR/preflight_report_${EXECUTION_ID}.md"

# Logging functions with colors
log_header() {
    local msg="$1"
    printf "${PURPLE}=================================================================${NC}\n"
    printf "${PURPLE}%s${NC}\n" "$msg"
    printf "${PURPLE}=================================================================${NC}\n"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [HEADER] $msg" >> "$PREFLIGHT_LOG"
}

log_section() {
    local msg="$1"
    printf "\n${CYAN}🔍 %s${NC}\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SECTION] $msg" >> "$PREFLIGHT_LOG"
}

log_success() {
    local msg="$1"
    printf "${GREEN}✅ %s${NC}\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $msg" >> "$PREFLIGHT_LOG"
}

log_warning() {
    local msg="$1"
    printf "${YELLOW}⚠️  %s${NC}\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $msg" >> "$PREFLIGHT_LOG"
}

log_error() {
    local msg="$1"
    printf "${RED}❌ %s${NC}\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $msg" >> "$PREFLIGHT_LOG"
}

log_info() {
    local msg="$1"
    printf "${BLUE}ℹ️  %s${NC}\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $msg" >> "$PREFLIGHT_LOG"
}

log_detail() {
    local msg="$1"
    printf "   %s\n" "$msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DETAIL] $msg" >> "$PREFLIGHT_LOG"
}

# =====================================================================
# GLOBAL VARIABLES FOR TRACKING
# =====================================================================

CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS_COUNT=0
CRITICAL_FAILURES=()
NON_CRITICAL_ISSUES=()
RECOMMENDATIONS=()

# =====================================================================
# CHECK FUNCTIONS
# =====================================================================

check_script_location() {
    log_section "Verifying Script Location"
    
    local current_dir="$(pwd)"
    local expected_location="tutorial-scripts"
    
    if [[ "$(basename "$current_dir")" == "$expected_location" ]]; then
        log_success "Script running from correct location: $current_dir"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        log_error "Script must be run from tutorial-scripts directory"
        log_detail "Current: $current_dir"
        log_detail "Expected: [somewhere]/tutorial-scripts"
        CRITICAL_FAILURES+=("Wrong script location")
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

check_operating_system() {
    log_section "Operating System Compatibility"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local macos_version="$(sw_vers -productVersion)"
        log_success "macOS detected: $macos_version"
        log_detail "Architecture: $(uname -m)"
        log_detail "Kernel: $(uname -r)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        
        # Check macOS version compatibility
        local major_version="$(echo "$macos_version" | cut -d. -f1)"
        local minor_version="$(echo "$macos_version" | cut -d. -f2)"
        
        if [[ "$major_version" -ge 12 ]] || [[ "$major_version" -eq 11 && "$minor_version" -ge 0 ]]; then
            log_success "macOS version compatible with Core Audio development"
        elif [[ "$major_version" -eq 10 && "$minor_version" -ge 15 ]]; then
            log_warning "macOS version may have limited Core Audio features"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
            NON_CRITICAL_ISSUES+=("Older macOS version")
        else
            log_error "macOS version too old for modern Core Audio development"
            CRITICAL_FAILURES+=("Incompatible macOS version")
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        
        return 0
    else
        log_error "Core Audio development requires macOS"
        log_detail "Detected OS: $OSTYPE"
        CRITICAL_FAILURES+=("Non-macOS operating system")
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

check_required_tools() {
    log_section "Required Development Tools"
    
    local tools_status=0
    
    # Xcode Command Line Tools
    if xcode-select -p > /dev/null 2>&1; then
        local xcode_path="$(xcode-select -p)"
        log_success "Xcode Command Line Tools installed"
        log_detail "Path: $xcode_path"
        
        # Test clang compiler
        if command -v clang > /dev/null 2>&1; then
            local clang_version="$(clang --version | head -n1)"
            log_success "Clang compiler available"
            log_detail "$clang_version"
        else
            log_error "Clang compiler not found"
            tools_status=1
        fi
    else
        log_error "Xcode Command Line Tools not installed"
        log_detail "Install with: xcode-select --install"
        CRITICAL_FAILURES+=("Missing Xcode Command Line Tools")
        tools_status=1
    fi
    
    # Git
    if command -v git > /dev/null 2>&1; then
        local git_version="$(git --version)"
        log_success "Git available"
        log_detail "$git_version"
    else
        log_error "Git not found"
        CRITICAL_FAILURES+=("Missing Git")
        tools_status=1
    fi
    
    # Curl
    if command -v curl > /dev/null 2>&1; then
        local curl_version="$(curl --version | head -n1)"
        log_success "Curl available"
        log_detail "$curl_version"
    else
        log_error "Curl not found"
        CRITICAL_FAILURES+=("Missing Curl")
        tools_status=1
    fi
    
    # Optional but recommended tools
    if command -v brew > /dev/null 2>&1; then
        log_success "Homebrew available (recommended for package management)"
        log_detail "$(brew --version)"
    else
        log_warning "Homebrew not found (recommended for installing additional tools)"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("Missing Homebrew")
        RECOMMENDATIONS+=("Install Homebrew for easier package management")
    fi
    
    if [[ $tools_status -eq 0 ]]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    
    return $tools_status
}

check_core_audio_framework() {
    log_section "Core Audio Framework Accessibility"
    
    # Test Core Audio header compilation
    local test_code='#include <AudioToolbox/AudioToolbox.h>
int main() { return 0; }'
    
    if echo "$test_code" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
        log_success "Core Audio framework accessible"
        log_detail "AudioToolbox framework can be compiled and linked"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        log_error "Core Audio framework not accessible"
        log_detail "Cannot compile test program with AudioToolbox framework"
        CRITICAL_FAILURES+=("Core Audio framework inaccessible")
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

check_day1_completion() {
    log_section "Day 1 Completion Status"
    
    # Source environment first
    local env_file="$BASE_DIR/.core-audio-env"
    if [[ -f "$env_file" ]]; then
        source "$env_file"
        log_success "Environment file found and sourced"
        log_detail "File: $env_file"
    else
        log_error "Environment file missing: $env_file"
        CRITICAL_FAILURES+=("Missing environment file")
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
    
    # Check required environment variables
    local env_status=0
    local required_vars=(
        "CORE_AUDIO_ROOT:Study guide repository path"
        "TUTORIAL_ROOT:Tutorial repository path"
        "LOGS_DIR:Session logs directory"
    )
    
    for var_info in "${required_vars[@]}"; do
        local var_name="${var_info%%:*}"
        local description="${var_info##*:}"
        local var_value="${!var_name}"
        
        if [[ -n "$var_value" ]]; then
            if [[ -d "$var_value" ]]; then
                log_success "$description configured and exists"
                log_detail "$var_name=$var_value"
            else
                log_error "$description directory missing: $var_value"
                env_status=1
            fi
        else
            log_error "$description not configured"
            env_status=1
        fi
    done
    
    # Check Day 1 session log
    local day1_log="$LOGS_DIR/day01_session.log"
    if [[ -f "$day1_log" ]]; then
        log_success "Day 1 session log found"
        log_detail "Log: $day1_log"
        
        # Check for completion marker
        if grep -q "DAY1-COMPLETE" "$day1_log"; then
            log_success "Day 1 completion marker verified"
        else
            log_warning "Day 1 completion marker not found in log"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
            NON_CRITICAL_ISSUES+=("Day 1 completion marker missing")
        fi
    else
        log_error "Day 1 session log missing: $day1_log"
        CRITICAL_FAILURES+=("Missing Day 1 session log")
        env_status=1
    fi
    
    # Check key directories and files
    local required_items=(
        "$TUTORIAL_ROOT:Tutorial repository directory"
        "$CORE_AUDIO_ROOT:Study guide repository directory"
        "$TUTORIAL_ROOT/activate-ca-env.sh:Environment activation script"
        "$TUTORIAL_ROOT/shared-frameworks:Testing frameworks directory"
        "$TUTORIAL_ROOT/daily-sessions/day01:Day 1 session directory"
    )
    
    for item_info in "${required_items[@]}"; do
        local item_path="${item_info%%:*}"
        local description="${item_info##*:}"
        
        if [[ -e "$item_path" ]]; then
            log_success "$description exists"
            log_detail "Path: $item_path"
        else
            log_error "$description missing: $item_path"
            env_status=1
        fi
    done
    
    if [[ $env_status -eq 0 ]]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        CRITICAL_FAILURES+=("Day 1 setup incomplete")
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    
    return $env_status
}

check_git_configuration() {
    log_section "Git Configuration"
    
    local git_status=0
    
    # Check global Git configuration
    local git_name="$(git config --global user.name 2>/dev/null || echo '')"
    local git_email="$(git config --global user.email 2>/dev/null || echo '')"
    
    if [[ -n "$git_name" ]]; then
        log_success "Git user name configured: $git_name"
    else
        log_warning "Git user name not configured globally"
        log_detail "Set with: git config --global user.name 'Your Name'"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("Git user name not configured")
        RECOMMENDATIONS+=("Configure Git user name before running setup")
    fi
    
    if [[ -n "$git_email" ]]; then
        log_success "Git user email configured: $git_email"
    else
        log_warning "Git user email not configured globally"
        log_detail "Set with: git config --global user.email 'your@email.com'"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("Git user email not configured")
        RECOMMENDATIONS+=("Configure Git user email before running setup")
    fi
    
    # Check if repositories are already Git initialized
    if [[ -d "$TUTORIAL_ROOT/.git" ]]; then
        log_info "Tutorial repository already Git initialized"
    else
        log_info "Tutorial repository will be Git initialized during setup"
    fi
    
    if [[ -d "$CORE_AUDIO_ROOT/.git" ]]; then
        log_info "Study guide repository already Git initialized"
    else
        log_info "Study guide repository will be Git initialized during setup"
    fi
    
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    return 0
}

check_github_access() {
    log_section "GitHub Access & Authentication"
    
    local auth_methods=()
    local auth_status=0
    
    # Check GitHub CLI
    if command -v gh > /dev/null 2>&1; then
        log_success "GitHub CLI installed"
        log_detail "$(gh --version | head -n1)"
        
        if gh auth status > /dev/null 2>&1; then
            local gh_user="$(gh api user --jq '.login' 2>/dev/null || echo 'unknown')"
            log_success "GitHub CLI authenticated as: $gh_user"
            auth_methods+=("GitHub CLI")
        else
            log_info "GitHub CLI installed but not authenticated"
            log_detail "Authenticate with: gh auth login"
        fi
    else
        log_info "GitHub CLI not installed (optional)"
        log_detail "Install with: brew install gh"
    fi
    
    # Test SSH access
    if ssh -T git@github.com -o ConnectTimeout=10 -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
        local ssh_user="$(ssh -T git@github.com 2>&1 | grep -o 'Hi [^!]*' | cut -d' ' -f2 || echo 'unknown')"
        log_success "SSH key authentication working for: $ssh_user"
        auth_methods+=("SSH Keys")
    else
        log_info "SSH key authentication not configured"
        log_detail "Set up with: ssh-keygen -t ed25519 -C 'your@email.com'"
    fi
    
    # Test HTTPS access (basic connectivity)
    if curl -s -f "https://api.github.com/rate_limit" > /dev/null 2>&1; then
        log_success "HTTPS GitHub connectivity working"
        log_info "Personal Access Token authentication available"
        auth_methods+=("HTTPS/PAT")
    else
        log_warning "GitHub HTTPS connectivity issues"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("GitHub connectivity issues")
    fi
    
    # Summary
    if [[ ${#auth_methods[@]} -gt 0 ]]; then
        log_success "GitHub authentication methods available: ${auth_methods[*]}"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "No GitHub authentication methods detected"
        log_detail "Setup will guide you through authentication configuration"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("No GitHub authentication configured")
        RECOMMENDATIONS+=("Set up GitHub authentication before running setup script")
        CHECKS_PASSED=$((CHECKS_PASSED + 1))  # Not critical, setup can handle this
    fi
    
    return 0
}

check_network_connectivity() {
    log_section "Network Connectivity"
    
    local connectivity_status=0
    
    # Test general internet connectivity
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        log_success "Internet connectivity available"
    else
        log_error "No internet connectivity"
        CRITICAL_FAILURES+=("No internet connectivity")
        connectivity_status=1
    fi
    
    # Test GitHub connectivity
    if curl -s -f -m 10 "https://github.com" > /dev/null 2>&1; then
        log_success "GitHub.com accessible"
    else
        log_error "Cannot reach GitHub.com"
        CRITICAL_FAILURES+=("GitHub inaccessible")
        connectivity_status=1
    fi
    
    # Test GitHub API
    if curl -s -f -m 10 "https://api.github.com/rate_limit" > /dev/null 2>&1; then
        log_success "GitHub API accessible"
    else
        log_warning "GitHub API accessibility issues"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("GitHub API issues")
    fi
    
    if [[ $connectivity_status -eq 0 ]]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    
    return $connectivity_status
}

check_disk_space() {
    log_section "Disk Space Availability"
    
    local tutorial_disk_usage="$(du -sh "$TUTORIAL_ROOT" 2>/dev/null | cut -f1 || echo 'unknown')"
    local mastery_disk_usage="$(du -sh "$CORE_AUDIO_ROOT" 2>/dev/null | cut -f1 || echo 'unknown')"
    local available_space="$(df -h "$BASE_DIR" | tail -n1 | awk '{print $4}' || echo 'unknown')"
    
    log_success "Disk space check completed"
    log_detail "Tutorial repository size: $tutorial_disk_usage"
    log_detail "Study guide repository size: $mastery_disk_usage"
    log_detail "Available space: $available_space"
    
    # Check if we have at least 1GB free space
    local available_mb="$(df -m "$BASE_DIR" | tail -n1 | awk '{print $4}' || echo '0')"
    if [[ "$available_mb" -gt 1024 ]]; then
        log_success "Sufficient disk space available"
    else
        log_warning "Low disk space detected"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        NON_CRITICAL_ISSUES+=("Low disk space")
    fi
    
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    return 0
}

check_file_permissions() {
    log_section "File Permissions"
    
    local permissions_status=0
    
    # Check write permissions for key directories
    local key_dirs=("$BASE_DIR" "$TUTORIAL_ROOT" "$CORE_AUDIO_ROOT" "$LOG_DIR")
    
    for dir in "${key_dirs[@]}"; do
        if [[ -w "$dir" ]]; then
            log_success "Write permission available: $(basename "$dir")"
        else
            log_error "No write permission: $dir"
            CRITICAL_FAILURES+=("No write permission for $dir")
            permissions_status=1
        fi
    done
    
    # Test creating a temporary file
    local test_file="$LOG_DIR/permission_test_$$"
    if touch "$test_file" 2>/dev/null && rm "$test_file" 2>/dev/null; then
        log_success "File creation/deletion permissions verified"
    else
        log_error "Cannot create/delete files in log directory"
        CRITICAL_FAILURES+=("File creation permission issues")
        permissions_status=1
    fi
    
    if [[ $permissions_status -eq 0 ]]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    
    return $permissions_status
}

# =====================================================================
# REPORT GENERATION
# =====================================================================

generate_preflight_report() {
    log_section "Generating Pre-Flight Report"
    
    cat > "$PREFLIGHT_REPORT" << REPORT_EOF
# Pre-Flight Check Report

**Date**: $(date)
**Execution ID**: $EXECUTION_ID
**Script Version**: $SCRIPT_VERSION

## Summary

- **✅ Checks Passed**: $CHECKS_PASSED
- **❌ Checks Failed**: $CHECKS_FAILED
- **⚠️ Warnings**: $WARNINGS_COUNT

## System Information

- **Operating System**: $(sw_vers -productName) $(sw_vers -productVersion)
- **Architecture**: $(uname -m)
- **User**: $(whoami)
- **Working Directory**: $(pwd)
- **Base Directory**: $BASE_DIR

## Critical Failures

$(if [[ ${#CRITICAL_FAILURES[@]} -eq 0 ]]; then
    echo "None - all critical checks passed! ✅"
else
    for failure in "${CRITICAL_FAILURES[@]}"; do
        echo "- ❌ $failure"
    done
fi)

## Non-Critical Issues

$(if [[ ${#NON_CRITICAL_ISSUES[@]} -eq 0 ]]; then
    echo "None - all optional checks passed! ✅"
else
    for issue in "${NON_CRITICAL_ISSUES[@]}"; do
        echo "- ⚠️ $issue"
    done
fi)

## Recommendations

$(if [[ ${#RECOMMENDATIONS[@]} -eq 0 ]]; then
    echo "None - system is optimally configured! ✅"
else
    for recommendation in "${RECOMMENDATIONS[@]}"; do
        echo "- 💡 $recommendation"
    done
fi)

## Readiness Assessment

$(if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo "🎉 **READY TO PROCEED** - All critical checks passed!"
    echo ""
    echo "You can now run the remote repository setup script:"
    echo "\`\`\`bash"
    echo "./remote_repo_setup.sh"
    echo "\`\`\`"
else
    echo "❌ **NOT READY** - Critical issues must be resolved first"
    echo ""
    echo "Please address the critical failures listed above before proceeding."
fi)

## Next Steps

$(if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo "1. **Run Remote Setup**: \`./remote_repo_setup.sh\`"
    echo "2. **Follow Setup Prompts**: Provide minimal required information"
    echo "3. **Verify Results**: Check generated logs and repositories"
    echo "4. **Continue to Day 2**: Foundation building phase"
else
    echo "1. **Resolve Critical Issues**: Address failures listed above"
    echo "2. **Re-run Pre-Flight Check**: \`./preflight_check.sh\`"
    echo "3. **Proceed When Ready**: Run remote setup script"
fi)

## Log Files

- **Pre-Flight Log**: $PREFLIGHT_LOG
- **Pre-Flight Report**: $PREFLIGHT_REPORT

---

*Generated by Core Audio Tutorial Pre-Flight Check*
REPORT_EOF

    log_success "Pre-flight report generated: $PREFLIGHT_REPORT"
}

display_final_summary() {
    printf "\n"
    log_header "PRE-FLIGHT CHECK COMPLETE"
    
    printf "\n${BLUE}📊 SUMMARY${NC}\n"
    printf "   ✅ Checks Passed: ${GREEN}%d${NC}\n" "$CHECKS_PASSED"
    printf "   ❌ Checks Failed: ${RED}%d${NC}\n" "$CHECKS_FAILED"
    printf "   ⚠️  Warnings: ${YELLOW}%d${NC}\n" "$WARNINGS_COUNT"
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        printf "\n${GREEN}🎉 READY TO PROCEED!${NC}\n"
        printf "${GREEN}All critical checks passed. You can now run:${NC}\n"
        printf "${CYAN}   ./remote_repo_setup.sh${NC}\n\n"
        
        if [[ $WARNINGS_COUNT -gt 0 ]]; then
            printf "${YELLOW}Note: There are %d warnings that should be addressed for optimal setup.${NC}\n" "$WARNINGS_COUNT"
            printf "${YELLOW}Check the detailed report for recommendations.${NC}\n\n"
        fi
        
        printf "${BLUE}📋 Detailed Report: ${NC}%s\n" "$PREFLIGHT_REPORT"
        printf "${BLUE}📊 Session Log: ${NC}%s\n\n" "$PREFLIGHT_LOG"
        
        return 0
    else
        printf "\n${RED}❌ NOT READY TO PROCEED${NC}\n"
        printf "${RED}%d critical issues must be resolved first:${NC}\n" "$CHECKS_FAILED"
        
        for failure in "${CRITICAL_FAILURES[@]}"; do
            printf "${RED}   • %s${NC}\n" "$failure"
        done
        
        printf "\n${YELLOW}Please resolve these issues and run the pre-flight check again.${NC}\n"
        printf "${BLUE}📋 Detailed Report: ${NC}%s\n" "$PREFLIGHT_REPORT"
        printf "${BLUE}📊 Session Log: ${NC}%s\n\n" "$PREFLIGHT_LOG"
        
        return 1
    fi
}

# =====================================================================
# MAIN EXECUTION
# =====================================================================

main() {
    log_header "$CHECK_NAME"
    
    printf "${BLUE}🚀 Running comprehensive pre-flight checks...${NC}\n"
    printf "${BLUE}📍 Execution ID: ${NC}%s\n" "$EXECUTION_ID"
    printf "${BLUE}📁 Base Directory: ${NC}%s\n" "$BASE_DIR"
    printf "${BLUE}📊 Logs: ${NC}%s\n\n" "$LOG_DIR"
    
    # Run all checks
    check_script_location
    check_operating_system
    check_required_tools
    check_core_audio_framework
    check_day1_completion
    check_git_configuration
    check_github_access
    check_network_connectivity
    check_disk_space
    check_file_permissions
    
    # Generate report and display summary
    generate_preflight_report
    display_final_summary
    
    # Return appropriate exit code
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function
main "$@"
