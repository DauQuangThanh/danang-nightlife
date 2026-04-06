#!/usr/bin/env bash
# Setup context assessment for brownfield project.
# Creates assessment environment and copies template.
#
# Usage: bash scripts/setup-context-assessment.sh [--json]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
JSON_MODE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--json]"
            echo ""
            echo "Options:"
            echo "  --json    Output results in JSON format"
            echo "  -h        Show this help"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument: $arg" >&2
            exit 2
            ;;
    esac
done

# Find repository root by searching upward for .git directory
find_repo_root() {
    local current
    current="$(pwd)"
    while [[ "$current" != "/" ]]; do
        if [[ -d "$current/.git" ]]; then
            echo "$current"
            return
        fi
        current="$(dirname "$current")"
    done
    # Fallback to current directory
    pwd
}

REPO_ROOT="$(find_repo_root)"
DOCS_DIR="$REPO_ROOT/docs"
CONTEXT_ASSESSMENT="$DOCS_DIR/context-assessment.md"
TEMPLATE="$SKILL_DIR/templates/context-assessment-template.md"

# Ensure docs directory exists
mkdir -p "$DOCS_DIR"

# Copy template
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$CONTEXT_ASSESSMENT"
    if [[ "$JSON_MODE" == false ]]; then
        echo "✓ Copied context assessment template to $CONTEXT_ASSESSMENT"
    fi
else
    if [[ "$JSON_MODE" == false ]]; then
        echo "WARNING: Context assessment template not found at $TEMPLATE" >&2
        echo "Creating empty assessment file" >&2
    fi
    touch "$CONTEXT_ASSESSMENT"
fi

# Check if we're in a git repo
if [[ -d "$REPO_ROOT/.git" ]]; then
    HAS_GIT="true"
else
    HAS_GIT="false"
fi

# Output results
if [[ "$JSON_MODE" == true ]]; then
    printf '{"CONTEXT_ASSESSMENT":"%s","DOCS_DIR":"%s","REPO_ROOT":"%s","HAS_GIT":"%s"}\n' \
        "$CONTEXT_ASSESSMENT" "$DOCS_DIR" "$REPO_ROOT" "$HAS_GIT"
else
    echo "Repository root: $REPO_ROOT"
    echo "Documentation directory: $DOCS_DIR"
    echo "Assessment file: $CONTEXT_ASSESSMENT"
    echo "Git repository: $HAS_GIT"
    echo ""
    echo "✓ Setup complete. Context assessment template is ready at:"
    echo "  $CONTEXT_ASSESSMENT"
fi
