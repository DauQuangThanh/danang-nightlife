#!/usr/bin/env bash
set -euo pipefail

# create-github-release.sh
# Create a GitHub release with the unified skills package
# Usage: create-github-release.sh <version>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"

# Remove 'v' prefix from version for release title
VERSION_NO_V=${VERSION#v}

gh release create "$VERSION" \
  .genreleases/nightlife-template-"$VERSION".zip \
  --title "Danang Nightlife - $VERSION_NO_V" \
  --notes-file release_notes.md
