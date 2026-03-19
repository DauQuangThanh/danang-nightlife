#!/usr/bin/env bash
set -euo pipefail

# create-github-release.sh
# Create a GitHub release with all template zip files
# Usage: create-github-release.sh <version>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"

# Remove 'v' prefix from version for release title
VERSION_NO_V=${VERSION#v}

gh release create "$VERSION" \
  .genreleases/nightlife-template-copilot-"$VERSION".zip \
  .genreleases/nightlife-template-claude-"$VERSION".zip \
  .genreleases/nightlife-template-gemini-"$VERSION".zip \
  .genreleases/nightlife-template-cursor-agent-"$VERSION".zip \
  .genreleases/nightlife-template-opencode-"$VERSION".zip \
  .genreleases/nightlife-template-qwen-"$VERSION".zip \
  .genreleases/nightlife-template-windsurf-"$VERSION".zip \
  .genreleases/nightlife-template-codex-"$VERSION".zip \
  .genreleases/nightlife-template-kilocode-"$VERSION".zip \
  .genreleases/nightlife-template-auggie-"$VERSION".zip \
  .genreleases/nightlife-template-roo-"$VERSION".zip \
  .genreleases/nightlife-template-codebuddy-"$VERSION".zip \
  .genreleases/nightlife-template-amp-"$VERSION".zip \
  .genreleases/nightlife-template-shai-"$VERSION".zip \
  .genreleases/nightlife-template-q-"$VERSION".zip \
  .genreleases/nightlife-template-bob-"$VERSION".zip \
  .genreleases/nightlife-template-jules-"$VERSION".zip \
  .genreleases/nightlife-template-qoder-"$VERSION".zip \
  .genreleases/nightlife-template-antigravity-"$VERSION".zip \
  --title "Danang Nightlife - $VERSION_NO_V" \
  --notes-file release_notes.md
