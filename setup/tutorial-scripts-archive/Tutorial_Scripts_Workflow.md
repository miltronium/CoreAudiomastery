# Core Audio Tutorial Scripts - Workflow Guide

## Overview

This document explains the complete workflow for managing tutorial scripts, commits, and progression through the Core Audio mastery tutorial.

## Repository Structure

```
~/Development/CoreAudio/
├── CoreAudioMastery/          # Study guide repository (final implementations)
├── CoreAudioTutorial/         # Tutorial progression repository  
├── logs/                      # Session logs and tracking
└── .core-audio-env           # Environment configuration
```

## Core Workflow Scripts

### 1. `archive_and_commit.sh` (New Combined Script)
**Purpose**: One-step archive and commit process for tutorial milestones

**Usage**:
```bash
./archive_and_commit.sh
```

**What it does**:
- Archives tutorial scripts to both repositories
- Commits changes with professional milestone messages  
- Pushes to GitHub automatically
- Logs all operations with detailed git output

### 2. `archive_tutorial_scripts.sh` (Standalone Archive)
**Purpose**: Archive tutorial scripts to repositories without committing

**Usage**:
```bash
./archive_tutorial_scripts.sh
```

**Options**:
- Option 1: Archive to CoreAudioMastery only
- Option 2: Archive to CoreAudioTutorial only  
- Option 3: Archive to both repositories
- Option 4: Custom location
- Option 5: Exit

### 3. `tutorial_scripts_commit.sh` (Standalone Commit)
**Purpose**: Commit and push archived files to GitHub

**Usage**:
```bash
./tutorial_scripts_commit.sh
```

**Features**:
- Enhanced git logging
- Multi-line commit message support
- Untracked file detection
- Push failure diagnosis

## Daily Tutorial Workflow

### Phase 1: Daily Session Work
1. **Create/modify tutorial scripts** in `tutorial-scripts/` directory
2. **Test and validate** all scripts work correctly
3. **Document progress** in session logs and notes

### Phase 2: Milestone Archiving (End of Session/Day)
**Option A: Combined Workflow (Recommended)**
```bash
# One command does everything
./archive_and_commit.sh
```

**Option B: Manual Steps**
```bash
# Step 1: Archive files
./archive_tutorial_scripts.sh
# Choose option 3 (both repositories)

# Step 2: Commit and push
./tutorial_scripts_commit.sh  
```

### Phase 3: Conversation Transition
After successful commit and push:
1. **Verify on GitHub** that changes are pushed
2. **Note completion** of current phase
3. **Start new conversation** for next tutorial phase with proper context

## Commit Message Standards

### Milestone Commits
Format:
```
feat: Complete [Phase] [Description]

- [Key achievement 1]
- [Key achievement 2] 
- [Key achievement 3]
- Ready for [Next Phase]

[Phase] Milestone: [Status] ✅
```

Example:
```
feat: Complete Day 1 setup and tutorial scripts archive

- Archive 16 tutorial setup scripts to both repositories
- Add comprehensive tutorial outline  
- Complete environment setup and validation
- Ready for Day 2: Foundation Building

Day 1 Milestone: Setup and Foundation ✅
```

### Feature Commits
Format:
```
feat: [Feature description]

- [Implementation detail 1]
- [Implementation detail 2]
```

### Fix Commits  
Format:
```
fix: [Issue description]

- [Fix detail 1]
- [Fix detail 2]
```

## Environment Variables

Required environment variables (set by setup):
```bash
CORE_AUDIO_ROOT="/Users/miltronius/Development/CoreAudio/CoreAudioMastery"
TUTORIAL_ROOT="/Users/miltronius/Development/CoreAudio/CoreAudioTutorial"  
LOGS_DIR="/Users/miltronius/Development/CoreAudio/logs"
CA_TUTORIAL_BASE="/Users/miltronius/Development/CoreAudio"
```

## Git Workflow Integration

### Branch Strategy
- **main**: Primary development branch for both repositories
- **Commits**: Professional milestone commits with detailed messages
- **Pushes**: Automatic to GitHub after each successful commit

### Repository Synchronization
Both repositories maintained in parallel:
- **CoreAudioMastery**: Study guide final implementations
- **CoreAudioTutorial**: Tutorial progression and session tracking

## Tutorial Progression Phases

### Phase 1: Foundation (Days 1-5)
- **Day 1**: Setup and Foundation ✅
- **Day 2**: Foundation Building
- **Day 3**: Chapter 1 Structure  
- **Day 4**: Testing Framework
- **Day 5**: CI/CD Setup

### Phase 2: Implementation (Days 6-12)
- **Day 6-8**: C Implementation (Basic → Enhanced → Professional)
- **Day 9**: C++ Implementation  
- **Day 10**: Objective-C Integration
- **Day 11-12**: Swift Modern Implementation

### Phase 3: Integration (Days 13-17)
- **Day 13**: Cross-language Integration
- **Day 14**: Answer Key Development
- **Day 15**: Enhancement Integration
- **Day 16**: Documentation Complete
- **Day 17**: Final Validation

### Phase 4: Consolidation (Days 18-21)
- **Day 18-19**: Self-Assessment & Practice
- **Day 20-21**: Teaching & Review

## Troubleshooting

### Common Issues

**Script not executable**:
```bash
chmod +x script_name.sh
```

**Environment not loaded**:
```bash
source /Users/miltronius/Development/CoreAudio/.core-audio-env
```

**Git push failures**:
- Check GitHub authentication
- Verify remote configuration: `git remote -v`
- Check branch protection rules

**Files not found for archiving**:
- Ensure running from `tutorial-scripts/` directory
- Verify file permissions and existence

### Debug Mode
Add debug output to any script:
```bash
set -x  # Enable debug tracing
# your commands here
set +x  # Disable debug tracing
```

## Best Practices

### Script Development
1. **Test scripts thoroughly** before archiving
2. **Use meaningful file names** and consistent naming
3. **Add error handling** and validation
4. **Document complex operations** with comments

### Commit Practices  
1. **Commit at logical milestones** (end of day/phase)
2. **Use professional commit messages** following standards
3. **Verify pushes succeed** before conversation transitions
4. **Keep commits atomic** and focused

### Documentation
1. **Update README files** as workflows evolve
2. **Maintain session logs** for progress tracking
3. **Document lessons learned** and debugging solutions
4. **Keep tutorial outline current** with actual progress

## Success Indicators

### Daily Session Success
- [ ] All scripts execute without errors
- [ ] Session objectives completed
- [ ] Progress logged and documented
- [ ] Ready for next session/phase

### Milestone Success  
- [ ] Files archived to both repositories
- [ ] Commits created with proper messages
- [ ] Pushes successful to GitHub
- [ ] Repositories synchronized
- [ ] Ready for next conversation/phase

## Integration with Study Schedule

This workflow integrates directly with the Core Audio mastery study schedule:
- **Daily sessions**: 2-3 hours focused implementation
- **Weekly milestones**: Major phase completions
- **Conversation boundaries**: Clear progression checkpoints
- **Repository evolution**: Continuous improvement and refinement

The workflow ensures consistent progress tracking, professional development practices, and seamless tutorial progression from Day 1 through final mastery validation.
