#!/bin/bash

# Master Archive and Commit Script V2
# Core Audio Tutorial - Branch-Aware Multi-Repository Management

set -e

echo "🚀 Core Audio Tutorial - Master Archive and Commit V2"
echo "===================================================="

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ORIGINAL_DIR=$(pwd)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

echo "⏰ Timestamp: $TIMESTAMP"
echo "📁 Starting location: $ORIGINAL_DIR"
echo "🌿 Current branch: $CURRENT_BRANCH"

# Function to safely commit in a repository
commit_repo() {
    local repo_path="$1"
    local repo_name="$2"
    local commit_message="$3"
    
    if [[ -d "$repo_path" && -d "$repo_path/.git" ]]; then
        echo "📝 Processing $repo_name repository..."
        cd "$repo_path"
        
        # Get current branch
        local BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
        echo "   🌿 Branch: $BRANCH"
        
        # Check if there are changes
        if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [[ -n $(git ls-files --others --exclude-standard) ]]; then
            echo "   📋 Changes found in $repo_name"
            git add .
            
            # Show brief status
            CHANGES=$(git status --porcelain | wc -l)
            echo "   📊 Files changed: $CHANGES"
            
            git commit -m "$commit_message"
            echo "   ✅ $repo_name committed successfully"
            
            # Ask about push
            echo "   📤 Push $repo_name to remote? (y/n)"
            read -r response
            if [[ "$response" == "y" ]]; then
                if git push origin "$BRANCH" 2>/dev/null; then
                    echo "   ✅ $repo_name pushed successfully"
                else
                    echo "   ⚠️  $repo_name push failed (may need to set remote)"
                fi
            else
                echo "   ⏭️  Skipping push for $repo_name"
            fi
        else
            echo "   ℹ️  No changes in $repo_name"
        fi
    else
        echo "   ⚠️  $repo_name not found or not a git repository: $repo_path"
    fi
}

# Step 1: Archive tutorial-scripts to both main repos
echo ""
echo "🔧 STEP 1: Archive tutorial-scripts to main repositories"
echo "======================================================"

if [[ -f "activate-ca-env.sh" ]]; then
    TUTORIAL_SCRIPTS_DIR="$(pwd)"
    echo "📁 Found tutorial scripts in: $TUTORIAL_SCRIPTS_DIR"
    
    # Get latest commit info
    LATEST_COMMIT=$(git rev-parse --short HEAD)
    
    # Archive to CoreAudioTutorial
    echo "📦 Archiving to CoreAudioTutorial..."
    if [[ -d "../CoreAudioTutorial" ]]; then
        cd ../CoreAudioTutorial
        mkdir -p tutorial-scripts-archive
        rsync -av --exclude='.git' --exclude='.DS_Store' "$TUTORIAL_SCRIPTS_DIR/" tutorial-scripts-archive/
        
        # Create branch info file
        echo "Branch: $CURRENT_BRANCH" > tutorial-scripts-archive/BRANCH_INFO.txt
        echo "Commit: $LATEST_COMMIT" >> tutorial-scripts-archive/BRANCH_INFO.txt
        echo "Date: $(date)" >> tutorial-scripts-archive/BRANCH_INFO.txt
        
        commit_repo "$(pwd)" "CoreAudioTutorial" "Archive tutorial-scripts: Day 2 complete - $CURRENT_BRANCH at $LATEST_COMMIT

- Environment activation system complete
- Multi-language build infrastructure working  
- Chapter 1 C Basic implementation done
- Tutorial scripts branch: $CURRENT_BRANCH
- Tutorial scripts commit: $LATEST_COMMIT"
    fi
    
    # Archive to CoreAudioMastery
    echo "📦 Archiving to CoreAudioMastery..."
    if [[ -d "../CoreAudioMastery" ]]; then
        cd ../CoreAudioMastery
        mkdir -p setup/tutorial-scripts-archive
        rsync -av --exclude='.git' --exclude='.DS_Store' "$TUTORIAL_SCRIPTS_DIR/" setup/tutorial-scripts-archive/
        
        # Create branch info file
        echo "Branch: $CURRENT_BRANCH" > setup/tutorial-scripts-archive/BRANCH_INFO.txt
        echo "Commit: $LATEST_COMMIT" >> setup/tutorial-scripts-archive/BRANCH_INFO.txt
        echo "Date: $(date)" >> setup/tutorial-scripts-archive/BRANCH_INFO.txt
        
        commit_repo "$(pwd)" "CoreAudioMastery" "Day 2 Complete: Chapter 1 C Basic + tutorial scripts archive

Chapter 1 Progress:
- C/basic: Complete with pure C implementation
- Added detailed metadata viewer
- Comprehensive test infrastructure
- Full documentation

Tutorial scripts archived from: $CURRENT_BRANCH at $LATEST_COMMIT"
    fi
    
    cd "$TUTORIAL_SCRIPTS_DIR"
fi

# Final summary
echo ""
echo "🎉 MASTER ARCHIVE COMPLETE!"
echo "=========================="
echo "⏰ Archive ID: $TIMESTAMP"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "📍 Commit: $LATEST_COMMIT"
echo ""
echo "📊 Day 2 Summary:"
echo "✅ Environment system created"
echo "✅ Build infrastructure for 4 languages"
echo "✅ Chapter 1 C Basic implementation"
echo "✅ Enhanced metadata viewer"
echo "✅ All work archived to main repos"
echo ""
echo "🚀 Ready for Day 3!"
