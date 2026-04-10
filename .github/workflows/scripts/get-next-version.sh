#!/usr/bin/env bash
set -euo pipefail

# get-next-version.sh
# Calculate the next version based on the latest git tag and output GitHub Actions variables
# Usage: get-next-version.sh

# Get the highest version tag by sorting all tags numerically.
# git describe --tags --abbrev=0 can return a stale tag when multiple tags
# point to the same commit, so we sort all version tags and pick the highest.
LATEST_TAG=$(git tag -l 'v[0-9]*.[0-9]*.[0-9]*' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
if [[ -z "$LATEST_TAG" ]]; then
  LATEST_TAG="v0.0.0"
fi
echo "latest_tag=$LATEST_TAG" >> "$GITHUB_OUTPUT"

# Extract version number and increment
VERSION=$(echo "$LATEST_TAG" | sed 's/v//')
IFS='.' read -ra VERSION_PARTS <<< "$VERSION"
MAJOR=${VERSION_PARTS[0]:-0}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

# Increment patch version
PATCH=$((PATCH + 1))
NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
echo "New version will be: $NEW_VERSION (latest tag: $LATEST_TAG)"
