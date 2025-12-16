#!/bin/bash

set -e

echo "======================================"
echo " Audio Transformer Suite 78"
echo " Git Rollback Utility"
echo "======================================"

# Ensure we are in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "❌ Not a git repository."
  exit 1
fi

BRANCH=$(git branch --show-current)

echo "Current branch: $BRANCH"
echo

echo "Choose rollback option:"
echo "1) Roll back to last pushed GitHub version (origin/$BRANCH)"
echo "2) Roll back to previous local commit (HEAD~1)"
echo "3) Abort"
read -p "Enter choice [1-3]: " choice

# Create safety backup branch
BACKUP_BRANCH="backup-before-rollback-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
echo "✔ Backup branch created: $BACKUP_BRANCH"
echo

case $choice in
  1)
    echo "Fetching latest from GitHub..."
    git fetch origin

    echo "Rolling back to origin/$BRANCH..."
    git reset --hard "origin/$BRANCH"
    ;;
  2)
    echo "Rolling back to previous commit (HEAD~1)..."
    git reset --hard HEAD~1
    ;;
  3)
    echo "Rollback aborted."
    exit 0
    ;;
  *)
    echo "❌ Invalid choice."
    exit 1
    ;;
esac

echo
echo "✔ Rollback complete."
echo "If needed, you can recover from:"
echo "  git checkout $BACKUP_BRANCH"
echo "======================================"
