#!/usr/bin/env bash
set -euo pipefail

# create-release-packages.sh (workflow-local)
# Build Danang Nightlife template release archive containing all skills.
# Usage: .github/workflows/scripts/create-release-packages.sh <version>
#   Version argument should include leading 'v'.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version-with-v-prefix>" >&2
  exit 1
fi
NEW_VERSION="$1"
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must look like v0.0.0" >&2
  exit 1
fi

echo "Building release package for $NEW_VERSION"

# Create and use .genreleases directory for all build artifacts
GENRELEASES_DIR=".genreleases"
mkdir -p "$GENRELEASES_DIR"
rm -rf "$GENRELEASES_DIR"/* || true

# Build unified template package with skills and agent-commands
build_template_package() {
  local base_dir="$GENRELEASES_DIR/nightlife-template-package"
  echo "Building unified template package..."
  mkdir -p "$base_dir"

  # Copy all skill subdirectories
  if [[ -d skills ]]; then
    cp -r skills "$base_dir/skills"
    echo "Copied all skills -> $base_dir/skills"
  else
    echo "Warning: skills directory not found"
    exit 1
  fi

  # Copy agent-commands directory
  if [[ -d agent-commands ]]; then
    cp -r agent-commands "$base_dir/agent-commands"
    echo "Copied agent-commands -> $base_dir/agent-commands"
  else
    echo "Warning: agent-commands directory not found, creating empty"
    mkdir -p "$base_dir/agent-commands"
  fi

  # Create the zip file
  ( cd "$base_dir" && zip -r "../nightlife-template-${NEW_VERSION}.zip" . )
  echo "Created $GENRELEASES_DIR/nightlife-template-${NEW_VERSION}.zip"
}

build_template_package

echo "Archive in $GENRELEASES_DIR:"
ls -1 "$GENRELEASES_DIR"/nightlife-template-"${NEW_VERSION}".zip
