#!/usr/bin/env bash

set -euo pipefail

# Ensure all variables are present
SOURCE="$1"
REPO="$2"
TARGET="$3"
BRANCH="$4"
GIT_USER="$5"
GIT_EMAIL="$6"
GIT_COMMIT_MSG="$7"
GIT_COMMIT_SIGN_OFF="$8"
EXCLUDES=()

if [[ -n ${9+x} ]]; then
    X=("${9//:/ }")
    for x in ${X[*]}; do
        EXCLUDES+=('--exclude')
        EXCLUDES+=("/$x")
    done
fi

# Create Temporary Directory
TEMP=$(mktemp -d)

# Setup git
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USER"
git clone "$REPO" "$TEMP"
cd "$TEMP"

# Check if branch exists
LS_REMOTE="$(git ls-remote --heads origin refs/heads/"$BRANCH")"
if [[ -n "$LS_REMOTE" ]]; then
  echo "Checking out $BRANCH from origin."
  git checkout "$BRANCH"
else
  echo "$BRANCH does not exist on origin, creating new branch."
  git checkout -b "$BRANCH"
fi

# Sync $TARGET folder to $REPO state repository with excludes
f="/"
if [[ -f "${GITHUB_WORKSPACE}/${SOURCE}" ]]; then
    f=""
fi
echo "running 'rsync -avh --delete ${EXCLUDES[*]} $GITHUB_WORKSPACE/${SOURCE}${f} $TEMP/$TARGET'"
rsync -avh --delete "${EXCLUDES[@]}" "$GITHUB_WORKSPACE/${SOURCE}${f}" "$TEMP/$TARGET"

# Success finish early if there are no changes
# i.e. up to date and branch exists
if [ -z "$(git status --porcelain)" ] && [ -n "$LS_REMOTE" ]; then
  echo "no changes to sync"
  exit 0
fi

# Add changes and push commit
git add .

commit_signoff=""
if [ "${GIT_COMMIT_SIGN_OFF}" = "true" ]; then
  commit_signoff="-s"
fi

if [[ -n "$GIT_COMMIT_MSG" ]]; then
  git commit ${commit_signoff} -m "$GIT_COMMIT_MSG"
else
  SHORT_SHA=$(echo "$GITHUB_SHA" | head -c 6)
  git commit ${commit_signoff} -F- <<EOF
Automatic CI SYNC Commit $SHORT_SHA

Syncing with $GITHUB_REPOSITORY commit $GITHUB_SHA
EOF
fi

if [[ -n "$LS_REMOTE" ]]; then
  git push
else
  git push origin "$BRANCH"
fi
