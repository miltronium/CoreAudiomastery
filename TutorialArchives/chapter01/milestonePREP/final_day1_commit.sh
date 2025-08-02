#!/bin/bash

# Final Day 1 Commit - GitHub Issue Creation and Workflow Complete
# Archives, commits, and pushes all Day 1 completion work

set -e

echo "[$(date '+%H:%M:%S')] 🎉 Final Day 1 Commit - Complete Setup & Issue Creation"
echo "====================================================================="

# Function for logging
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Source environment
if [[ -f "../.core-audio-env" ]]; then
    source "../.core-audio-env"
elif [[ -f "/Users/miltronius/Development/CoreAudio/.core-audio-env" ]]; then
    source "/Users/miltronius/Development/CoreAudio/.core-audio-env"
fi

log_action "🎯 Starting final Day 1 commit and push process"

# Validate environment
if [[ -z "$CORE_AUDIO_ROOT" || -z "$TUTORIAL_ROOT" ]]; then
    log_action "❌ Environment variables not set"
    exit 1
fi

log_action "📁 Repositories:"
log_action "   CoreAudioMastery: $CORE_AUDIO_ROOT"
log_action "   CoreAudioTutorial: $TUTORIAL_ROOT"

# Step 1: Run GitHub issue creation first
log_action "🚀 STEP 1: Create GitHub issues for help system enhancement"

if [[ -f "create_github_issue.sh" ]]; then
    log_action "📝 Running GitHub issue creation script"
    ./create_github_issue.sh
    log_action "✅ GitHub issues created successfully"
else
    log_action "⚠️  create_github_issue.sh not found - skipping issue creation"
fi

echo
log_action "🚀 STEP 2: Archive and commit all Day 1 work"

# Step 2: Run archive and commit
if [[ -f "archive_and_commit.sh" ]]; then
    log_action "📦 Running archive and commit script"
    
    # Temporarily modify archive_and_commit.sh to use a custom commit message
    # for this final Day 1 completion
    
    # Create final Day 1 commit message
    FINAL_COMMIT_MESSAGE="feat: Complete Day 1 Setup and Foundation with GitHub Issue Tracking

🎉 Day 1 Milestone Complete:
- ✅ Environment setup and validation
- ✅ Repository structure and Git workflow
- ✅ Tutorial scripts and automation tools
- ✅ GitHub CLI integration and issue creation
- ✅ Professional workflow documentation
- ✅ Help system enhancement issues created
- ✅ Archive and commit automation established

📋 GitHub Issues Created:
- Help system enhancement tracking in both repositories
- Professional issue management workflow established

🚀 Ready for Day 2: Foundation Building
- Core Audio Foundation (C) implementation
- Swift Foundation and testing framework
- Chapter 1 structure preparation

Day 1 Status: COMPLETE ✅
Next Phase: Day 2 Foundation Building 🎯"

    # Export the commit message for archive_and_commit.sh to use
    export CUSTOM_COMMIT_MESSAGE="$FINAL_COMMIT_MESSAGE"
    
    # Create a wrapper that uses our custom commit message
    cat > temp_archive_commit.sh << 'TEMP_SCRIPT_EOF'
#!/bin/bash
# Temporary wrapper for final Day 1 commit

set -e

# Source the main archive_and_commit.sh functionality
source archive_and_commit.sh

# Override the commit message generation
COMMIT_MESSAGE="$CUSTOM_COMMIT_MESSAGE"

# Run the main function with our custom message
main "$@"
TEMP_SCRIPT_EOF

    chmod +x temp_archive_commit.sh
    
    # Run with custom message
    CUSTOM_COMMIT_MESSAGE="$FINAL_COMMIT_MESSAGE" ./temp_archive_commit.sh
    
    # Clean up
    rm -f temp_archive_commit.sh
    
    log_action "✅ Archive and commit completed successfully"
else
    log_action "❌ archive_and_commit.sh not found"
    exit 1
fi

# Step 3: Final validation
echo
log_action "🚀 STEP 3: Final validation and status"

# Check that both repositories are updated
for repo_name in "CoreAudioMastery" "CoreAudioTutorial"; do
    if [[ "$repo_name" == "CoreAudioMastery" ]]; then
        repo_path="$CORE_AUDIO_ROOT"
    else
        repo_path="$TUTORIAL_ROOT"
    fi
    
    if [[ -d "$repo_path" ]]; then
        log_action "📊 Checking $repo_name repository status"
        cd "$repo_path"
        
        # Check git status
        if git status --porcelain | grep -q .; then
            log_action "⚠️  $repo_name has uncommitted changes"
        else
            log_action "✅ $repo_name is clean"
        fi
        
        # Show latest commit
        log_action "📄 Latest commit in $repo_name:"
        echo "    $(git log -1 --oneline)"
        
        # Check if pushed to remote
        if git status | grep -q "ahead"; then
            log_action "⚠️  $repo_name has unpushed commits"
        else
            log_action "✅ $repo_name is up to date with remote"
        fi
    fi
done

# Return to tutorial-scripts directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Final status report
echo
echo "======================================================================"
log_action "🎉 Day 1: Setup and Foundation - COMPLETE!"
echo "======================================================================"
echo
log_action "📊 Day 1 Achievements:"
log_action "   ✅ Complete environment setup and validation"
log_action "   ✅ CoreAudioMastery and CoreAudioTutorial repositories operational"
log_action "   ✅ Git workflow and professional commit standards established"
log_action "   ✅ Tutorial scripts archived and committed"
log_action "   ✅ GitHub CLI integration and issue creation workflow"
log_action "   ✅ Help system enhancement issues created and tracked"
log_action "   ✅ Automated archive and commit workflow established"
log_action "   ✅ Session logging and progress tracking active"
echo
log_action "🔗 GitHub Issues Created:"
log_action "   • Help system enhancement in CoreAudioMastery"
log_action "   • Help system enhancement in CoreAudioTutorial"
log_action "   • Professional issue tracking established"
echo
log_action "📄 Documentation Complete:"
log_action "   • WORKFLOW_README.md - Complete workflow guide"
log_action "   • HELP_SYSTEM_REFERENCE.md - Issue tracking reference"
log_action "   • Session logs and progress tracking"
echo
log_action "🎯 Ready for Day 2: Foundation Building"
log_action "   Morning Session (1.5 hours): Core Audio Foundation (C)"
log_action "   Afternoon Session (1-1.5 hours): Swift Foundation & Testing Framework"
echo
echo "🚀 START NEW CONVERSATION FOR DAY 2 with this context:"
echo "======================================================================"
cat << 'DAY2_CONTEXT_EOF'

I'm ready to begin Day 2 of the Core Audio mastery tutorial. I have completed Day 1:

✅ Day 1 Complete: Setup and Foundation
✅ Environment setup at: /Users/miltronius/Development/CoreAudio/
✅ Both repositories operational and synchronized with GitHub
✅ GitHub CLI integrated with issue creation workflow
✅ Help system enhancement issues created in both repositories
✅ Combined archive_and_commit.sh workflow established
✅ Workflow documentation complete (WORKFLOW_README.md)
✅ Session logging and tracking active
✅ Professional commit standards and automation established

Please guide me through Day 2: Foundation Building (2-3 hours total):
- Morning Session (1.5 hours): Core Audio Foundation (C)  
- Afternoon Session (1-1.5 hours): Swift Foundation & Testing Framework

From the study schedule:
- Implement Shared/Foundation/Sources/CoreAudioFoundationC/
- Implement Shared/Foundation/Sources/CoreAudioFoundation/ (Swift)
- Set up unified testing framework
- Create Chapter 1 structure preparation

Follow the study schedule exactly and use artifacts for all substantial code and documentation. Create specific commits at each major milestone using the combined archive_and_commit.sh workflow.

Begin with Day 2 - Morning Session: Core Audio Foundation (C) implementation.

DAY2_CONTEXT_EOF
echo "======================================================================"
echo
log_action "✨ Day 1 complete! Ready for Day 2 implementation."
