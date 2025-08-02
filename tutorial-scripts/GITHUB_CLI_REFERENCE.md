# GitHub CLI Quick Reference

## Installation Complete ✅
GitHub CLI (gh) is now installed and authenticated.

## Common Commands

### Issues
```bash
# Create an issue
gh issue create --title "Issue title" --body "Issue description"

# List issues
gh issue list

# View an issue
gh issue view 123

# Close an issue
gh issue close 123
```

### Repository
```bash
# View repository
gh repo view

# Clone a repository
gh repo clone owner/repo

# Create a repository
gh repo create repo-name
```

### Authentication
```bash
# Check auth status
gh auth status

# Login again if needed
gh auth login

# Logout
gh auth logout
```

### Pull Requests
```bash
# Create a PR
gh pr create --title "PR title" --body "PR description"

# List PRs
gh pr list

# View a PR
gh pr view 123
```

## Help System
```bash
# Get help for any command
gh help
gh issue help
gh repo help
```

## Next Steps
You can now use the `create_github_issue.sh` script to automatically create
the help system enhancement issue!

## Documentation
- Official docs: https://cli.github.com/manual/
- GitHub CLI repo: https://github.com/cli/cli
