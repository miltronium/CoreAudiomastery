#!/bin/bash
# Temporary wrapper for final Day 1 commit

set -e

# Source the main archive_and_commit.sh functionality
source archive_and_commit.sh

# Override the commit message generation
COMMIT_MESSAGE="$CUSTOM_COMMIT_MESSAGE"

# Run the main function with our custom message
main "$@"
