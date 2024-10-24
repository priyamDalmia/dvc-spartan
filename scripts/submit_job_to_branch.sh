#!/bin/bash

set -e

# Usage: ./carry_over_changes.sh <name> <branch_a> <branch_b>
# Example: ./carry_over_changes.sh "John Doe" "a" "b"

SUBMISSION_BRANCH="dev"
JOBS_BRANCH="jobs-spartan"

# only submits jobs from the 'dev' branch 
# checks if current branch is 'dev'
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "dev" ]; then 
    echo "Error: Must be on the dev branch to proceed"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi 


# checks if jobs branch exists locally
if ! git rev-parse --verify "$JOBS_BRANCH" >/dev/null 2>&1; then 
    echo "Jobs branch $JOBS_BRANCH does not exist"
    exit 1 
fi 

# check if both branchs have remotes setup
REMOTE_SUB=$(git ls-remote --heads origin "$SUBMISSION_BRANCH")
REMOTE_JOBS=$(git ls-remote --heads origin "$JOBS_BRANCH")

if [-z "$REMOTE_SUB"]; then 
    echo "Error: remote for branch \'$SUBMISSION_BRANCH\' not found"
    exit 1
fi 

# Get the current date in the format YYYY-MM-DD
DATE=$(date +"%Y-%m-%d")

echo "Script ran succesfully!!"
