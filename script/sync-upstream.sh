#!/usr/bin/env bash
set -euo pipefail

# sync-upstream.sh
# Pulls latest changes from dstrml/wu into the current YK Editor repository.

UPSTREAM_URL="https://github.com/dstrml/wu.git"
UPSTREAM_BRANCH="main"

echo "=== YK Editor Upstream Sync ==="
echo "Checking remote 'upstream' ($UPSTREAM_URL)..."

if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "Adding upstream remote: $UPSTREAM_URL"
    git remote add upstream "$UPSTREAM_URL"
else
    git remote set-url upstream "$UPSTREAM_URL"
fi

echo "Fetching latest changes from upstream..."
git fetch upstream "$UPSTREAM_BRANCH"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
NEW_COMMITS=$(git log HEAD..upstream/"$UPSTREAM_BRANCH" --oneline)

if [ -z "$NEW_COMMITS" ]; then
    echo "✓ Already up to date with upstream ($UPSTREAM_URL)!"
    exit 0
fi

COUNT=$(git rev-list --count HEAD..upstream/"$UPSTREAM_BRANCH")
echo "Found $COUNT new commit(s) from upstream:"
git log HEAD..upstream/"$UPSTREAM_BRANCH" --pretty=format:"  * %C(yellow)%h%Creset %s %C(dim)(%an, %ar)%Creset"
echo ""

echo "Merging upstream/$UPSTREAM_BRANCH into $CURRENT_BRANCH..."
if git merge upstream/"$UPSTREAM_BRANCH"; then
    echo "✓ Successfully merged upstream changes!"
    
    echo "Pushing changes to origin $CURRENT_BRANCH..."
    git push origin "$CURRENT_BRANCH"
    echo "✓ Pushed cleanly to origin!"
else
    echo "⚠️  Merge conflicts encountered. Please resolve the conflicts in the working tree, commit, and push."
    exit 1
fi
