#!/bin/bash

# Day 2 Branch Setup - Local Branch Structure
# This script sets up proper branch structure for session tracking

set -e

echo "[$(date '+%H:%M:%S')] Setting up Day 2 session branch structure"
echo "============================================================"

# Function to log actions
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# 1. Create day01-foundation branch from initial commit to preserve Day 1 work
log_action "Creating day01-foundation branch to preserve Day 1 work..."
git checkout e65c43a  # Initial commit
git checkout -b day01-foundation 2>/dev/null || {
    log_action "day01-foundation branch already exists, checking out..."
    git checkout day01-foundation
}

# 2. Create day02-environment branch from current feature branch
log_action "Creating day02-environment branch from current work..."
git checkout feature/day02-tutorialscripts
git checkout -b day02-environment 2>/dev/null || {
    log_action "day02-environment branch already exists, checking out..."
    git checkout day02-environment
}

# 3. Create a backup tag of current state
log_action "Creating backup tag of current state..."
git tag -a "backup-day2-start-$(date +%Y%m%d-%H%M%S)" -m "Backup before Day 2 session execution"

# 4. Create session tracking structure
log_action "Creating session tracking structure..."
mkdir -p daily-sessions/day02
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Day 2 Morning Session Started" > daily-sessions/day02/morning-session.log
echo "Branch: day02-environment" >> daily-sessions/day02/morning-session.log
echo "Starting commit: $(git rev-parse --short HEAD)" >> daily-sessions/day02/morning-session.log

# 5. Create progress summary if it doesn't exist
if [ ! -f progress-summary.md ]; then
    cat > progress-summary.md << 'PROGRESS_EOF'
# Core Audio Tutorial Progress Summary

## Completed Sessions

### Day 1: Setup and Foundation ✅
- Repository initialization
- Directory structure creation
- Git repository setup
- Testing framework installation
- Branch: `day01-foundation`

### Day 2: Foundation Building 🚀
- **Morning Session**: In Progress
- Branch: `day02-environment`
- Starting time: $(date '+%Y-%m-%d %H:%M:%S')

## Git Branch Structure
```
main                    # Stable releases
day01-foundation        # Day 1 work (protected)
day02-environment       # Day 2 work (active)
```

## Note
This tutorial-scripts repository is designed to be copied into:
- CoreAudioTutorial/tutorial-scripts/
- CoreAudioMastery/setup/tutorial-scripts/
PROGRESS_EOF
fi

# 6. Commit the session tracking setup
git add daily-sessions/ progress-summary.md || true
git commit -m "Day 2 Setup: Initialize session tracking and branch structure" || log_action "No changes to commit"

# 7. Show current branch structure
log_action "Current branch structure:"
git branch -v

log_action "✅ Branch setup complete!"
echo
echo "Current branch: $(git branch --show-current)"
echo "Session log: daily-sessions/day02/morning-session.log"
echo
echo "📝 This tutorial-scripts repo will be archived within:"
echo "   - CoreAudioTutorial/tutorial-scripts/"
echo "   - CoreAudioMastery/setup/tutorial-scripts/"
echo
echo "Ready to proceed with Day 2 Morning Session implementation!"
echo
echo "📝 Next step: ./day02_morning_session.sh"
