#!/bin/bash

# Master Sync Script - Archives tutorial-scripts to both main repos
# Run this from tutorial-scripts directory

echo "🔄 Master Sync Process Starting"
echo "=============================="
echo

# 1. Ensure we're in tutorial-scripts
if [[ ! -f "activate-ca-env.sh" ]]; then
    echo "❌ Must run from tutorial-scripts directory"
    exit 1
fi

TUTORIAL_SCRIPTS_DIR=$(pwd)

# 2. Check git status
echo "📊 Checking git status..."
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Uncommitted changes detected. Please commit first."
    git status
    exit 1
fi

# 3. Get current branch and latest commit
CURRENT_BRANCH=$(git branch --show-current)
LATEST_COMMIT=$(git rev-parse --short HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"
echo "📍 Latest commit: $LATEST_COMMIT"
echo

# 4. Archive to CoreAudioTutorial
echo "📦 Archiving to CoreAudioTutorial..."
cd ../CoreAudioTutorial
mkdir -p tutorial-scripts-archive

# Copy tutorial-scripts (excluding .git)
rsync -av --exclude='.git' --exclude='.DS_Store' "$TUTORIAL_SCRIPTS_DIR/" tutorial-scripts-archive/

# Git operations for CoreAudioTutorial
git add tutorial-scripts-archive/
git commit -m "Archive tutorial-scripts: Day 2 complete - $CURRENT_BRANCH at $LATEST_COMMIT

- Environment activation system complete
- Multi-language build infrastructure working
- Chapter 1 C Basic implementation done
- Tutorial scripts branch: $CURRENT_BRANCH
- Tutorial scripts commit: $LATEST_COMMIT"

echo "✅ CoreAudioTutorial archive complete"
echo

# 5. Archive to CoreAudioMastery
echo "📦 Archiving to CoreAudioMastery..."
cd ../CoreAudioMastery
mkdir -p setup/tutorial-scripts-archive

# Copy tutorial-scripts (excluding .git)
rsync -av --exclude='.git' --exclude='.DS_Store' "$TUTORIAL_SCRIPTS_DIR/" setup/tutorial-scripts-archive/

# Git operations for CoreAudioMastery
git add .
git commit -m "Day 2 Complete: Chapter 1 C Basic implementation + tutorial scripts archive

Chapter 1 Progress:
- C/basic: Complete with pure C implementation
- Added detailed metadata viewer
- Comprehensive test infrastructure
- Full documentation

Tutorial scripts archived at: $CURRENT_BRANCH / $LATEST_COMMIT"

echo "✅ CoreAudioMastery archive complete"
echo

# 6. Return to tutorial-scripts
cd "$TUTORIAL_SCRIPTS_DIR"

# 7. Summary
echo "📊 Sync Summary"
echo "=============="
echo "✅ Tutorial scripts archived to both repos"
echo "✅ Chapter 1 C Basic implementation included"
echo "✅ Ready for remote push"
echo
echo "📤 Next steps:"
echo "  1. cd ../CoreAudioTutorial && git push origin main"
echo "  2. cd ../CoreAudioMastery && git push origin main"
echo "  3. (Optional) Tag this milestone:"
echo "     git tag -a 'day2-complete' -m 'Day 2: Environment + Chapter 1 Basic'"
echo
echo "🎯 Day 2 artifacts successfully preserved!"
