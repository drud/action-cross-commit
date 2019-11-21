#!/usr/bin/env bash

set -euo pipefail

# Ensure all variables are present
SOURCE="$1"
REPO="$2"
TARGET="$3"
BRANCH="$4"
GIT_USER="$5"
GIT_EMAIL="$6"
EXCLUDES=()
if [[ ! -z ${7+x} ]]; then
    X=(${7//:/ })
    for x in "${X[@]}"; do
        EXCLUDES+=('--exclude')
        EXCLUDES+=("/$x")
    done
fi

# Create Temporary Directory
TEMP=$(mktemp -d)

# Setup git
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER
git clone $REPO $TEMP
cd $TEMP
git checkout $BRANCH

# Sync $TARGET folder to $REPO state repository with excludes
echo "running 'rsync -avh --delete "${EXCLUDES[@]}" $GITHUB_WORKSPACE/$SOURCE/ $TEMP/$TARGET'"
rsync -avh --delete "${EXCLUDES[@]}" $GITHUB_WORKSPACE/$SOURCE/ $TEMP/$TARGET

# Success finish early if there are no changes
if git diff --no-ext-diff --quiet; then
  echo "no changes to sync"
  exit 0
fi

# Add changes and push commit
git add .
SHORT_SHA=$(echo $GITHUB_SHA | head -c 6)
git commit -F- <<EOF
Automatic CI SYNC Commit $SHORT_SHA

Syncing with $GITHUB_REPOSITORY commit $GITHUB_SHA
EOF
git push
