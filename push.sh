#!/bin/bash

# Exit on error
set -e

# Function to display usage
usage() {
    echo "Usage: $0 \"Pull Request Title (with optional #issue reference)\""
    exit 1
}

# Check if a title was provided
if [ -z "$1" ]; then
    usage
fi

# Variables
PR_TITLE="$1"                                   # Pull Request title from argument
BRANCH_NAME="temp-branch-$(date +%s)"          # Unique branch name with timestamp
MAIN_BRANCH="main"                             # Main branch name
REMOTE="origin"                                # Remote name (default is 'origin')

# Step 1: Create and checkout a new branch
git checkout -b "$BRANCH_NAME"

# Step 2: Add all changes and commit
git add .
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
    exit 0
fi
git commit -m "$PR_TITLE"

# Step 3: Push the new branch to GitHub
git push "$REMOTE" "$BRANCH_NAME"

# Step 4: Open a Pull Request using GitHub CLI
gh pr create --base "$MAIN_BRANCH" --title "$PR_TITLE" --body "Automated PR: $PR_TITLE"

# Step 5: Merge the Pull Request (requires GitHub CLI)
gh pr merge --auto --delete-branch

# Step 6: Cleanup local branch
git checkout "$MAIN_BRANCH"
git branch -d "$BRANCH_NAME"

# Done
echo "Pull request created, merged, and cleaned up successfully!"

