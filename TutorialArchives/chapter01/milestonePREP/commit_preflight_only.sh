#!/bin/bash

# Commit Pre-Flight Check Script Only
# Clean, individual commit after successful preflight validation

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Committing Pre-Flight Check Script (Successful Run)${NC}"
echo "============================================================="

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

# Source environment
if [[ -f "$BASE_DIR/.core-audio-env" ]]; then
    source "$BASE_DIR/.core-audio-env"
    echo -e "${GREEN}✅ Environment loaded from: $BASE_DIR/.core-audio-env${NC}"
else
    echo -e "${YELLOW}⚠️  Environment file not found, using defaults${NC}"
    TUTORIAL_ROOT="$BASE_DIR/CoreAudioTutorial"
fi

echo -e "${BLUE}📁 Working in: $TUTORIAL_ROOT${NC}"

# Navigate to tutorial root
cd "$TUTORIAL_ROOT"

# Check if we're in a git repository
if [[ ! -d ".git" ]]; then
    echo -e "${YELLOW}⚠️  Not in a git repository, initializing...${NC}"
    git init
    git branch -M main
fi

# Check current status
echo -e "\n${BLUE}📋 Current Git Status:${NC}"
git status --porcelain

# Verify preflight_check.sh exists
if [[ ! -f "tutorial-scripts/preflight_check.sh" ]]; then
    echo -e "${YELLOW}⚠️  preflight_check.sh not found in tutorial-scripts/${NC}"
    echo -e "${CYAN}📍 Current directory structure:${NC}"
    ls -la tutorial-scripts/ 2>/dev/null || echo "tutorial-scripts/ directory not found"
    echo -e "\n${BLUE}💡 Please ensure preflight_check.sh is saved before committing${NC}"
    exit 1
fi

# Show the specific file we're committing
echo -e "\n${BLUE}📦 File to be committed:${NC}"
echo -e "   ${GREEN}✅ tutorial-scripts/preflight_check.sh${NC}"

# Check if preflight_check.sh is executable
if [[ -x "tutorial-scripts/preflight_check.sh" ]]; then
    echo -e "   ${GREEN}✅ Executable permissions set${NC}"
else
    echo -e "   ${YELLOW}⚠️  Making script executable...${NC}"
    chmod +x tutorial-scripts/preflight_check.sh
fi

# Show file info
echo -e "\n${BLUE}📄 File Information:${NC}"
echo -e "   Size: $(ls -lh tutorial-scripts/preflight_check.sh | awk '{print $5}')"
echo -e "   Permissions: $(ls -l tutorial-scripts/preflight_check.sh | awk '{print $1}')"
echo -e "   Modified: $(ls -l tutorial-scripts/preflight_check.sh | awk '{print $6, $7, $8}')"

# Add only the preflight script
echo -e "\n${BLUE}📦 Staging preflight_check.sh...${NC}"
git add tutorial-scripts/preflight_check.sh

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${GREEN}✅ preflight_check.sh already committed or no changes detected${NC}"
    echo -e "${BLUE}📊 Current commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'No commits yet')${NC}"
    exit 0
fi

# Show staged changes
echo -e "\n${BLUE}📋 Staged changes:${NC}"
git diff --cached --name-status

# Verify only preflight_check.sh is staged
STAGED_FILES=$(git diff --cached --name-only)
if [[ "$STAGED_FILES" != "tutorial-scripts/preflight_check.sh" ]]; then
    echo -e "${YELLOW}⚠️  Multiple files staged, showing what will be committed:${NC}"
    echo -e "${CYAN}$STAGED_FILES${NC}"
    echo ""
    read -p "Continue with commit? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Commit cancelled${NC}"
        exit 1
    fi
fi

# Create focused commit message for preflight check
COMMIT_MESSAGE="Add pre-flight check script with successful validation

🔍 Pre-Flight Check Features:
✅ Comprehensive system compatibility verification
✅ Day 1 completion status validation
✅ GitHub authentication method detection
✅ Development tools verification (Xcode, Git, Clang)
✅ Core Audio framework accessibility testing
✅ Network connectivity and GitHub API validation
✅ Disk space and file permissions checking

📊 Validation Results:
✅ Successfully passed all critical checks
✅ System ready for remote repository setup
✅ Color-coded output for easy reading
✅ Detailed logging with multiple log files
✅ Comprehensive markdown report generation

🎯 Script Capabilities:
- 10 comprehensive validation checks
- Smart error detection and recommendations
- Professional logging to console and files
- Generates detailed reports for troubleshooting
- Exit codes for script chaining compatibility

📝 Execution Confirmed:
- Script runs successfully from tutorial-scripts/
- All critical validations pass
- Ready to proceed with remote repository setup
- Clean working environment verified

Generated: $(date)
User: $(whoami)
Next: Save and run remote_repo_setup.sh"

# Commit the preflight script
echo -e "\n${BLUE}💾 Committing preflight_check.sh...${NC}"
git commit -m "$COMMIT_MESSAGE"

# Show commit summary
echo -e "\n${GREEN}✅ Successfully committed preflight_check.sh!${NC}"
echo -e "${BLUE}📊 Latest commit:${NC}"
git log --oneline -1

# Show current status
echo -e "\n${BLUE}📋 Repository Status After Commit:${NC}"
echo -e "   Branch: ${GREEN}$(git branch --show-current)${NC}"
echo -e "   Commit: ${YELLOW}$(git rev-parse --short HEAD)${NC}"
echo -e "   Working Directory: ${GREEN}$(git status --porcelain | wc -l | tr -d ' ') uncommitted changes${NC}"

# Check for remote
if git remote get-url origin > /dev/null 2>&1; then
    echo -e "   Remote: ${BLUE}$(git remote get-url origin)${NC}"
    echo -e "   ${YELLOW}Note: Committed locally - will sync during remote setup${NC}"
else
    echo -e "   Remote: ${YELLOW}Not configured yet${NC}"
fi

# Show next steps
echo -e "\n${GREEN}🎯 Pre-Flight Check Script Successfully Committed!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "   1. Save remote_repo_setup.sh from artifact"
echo -e "   2. Make executable: ${CYAN}chmod +x tutorial-scripts/remote_repo_setup.sh${NC}"
echo -e "   3. Run: ${CYAN}./remote_repo_setup.sh${NC}"
echo -e "   4. Commit after successful run"
echo -e "\n${GREEN}🚀 Ready for next step in clean progression!${NC}"
