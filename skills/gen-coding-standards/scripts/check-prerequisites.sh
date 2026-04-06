#!/usr/bin/env bash
# Check prerequisites for the coding-standards skill.
# Usage: bash scripts/check-prerequisites.sh [--json]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

JSON_OUTPUT=false
[[ "${1:-}" == "--json" ]] && JSON_OUTPUT=true

# Find repository root by ascending from current directory
find_repo_root() {
    local dir
    dir="$(pwd)"
    for _ in $(seq 1 16); do
        if [[ -d "$dir/.git" ]] || [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/README.md" ]]; then
            echo "$dir"
            return
        fi
        local parent
        parent="$(dirname "$dir")"
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done
    pwd
}

REPO_ROOT="$(find_repo_root)"
DOCS_DIR="$REPO_ROOT/docs"

# Case-insensitive file check
find_file() {
    local dir="$1" name="$2"
    [[ -d "$dir" ]] || return 1
    # Try exact match first, then case-insensitive
    if [[ -f "$dir/$name" ]]; then
        echo "$dir/$name"
        return 0
    fi
    local found
    found="$(find "$dir" -maxdepth 1 -iname "$name" -print -quit 2>/dev/null)"
    if [[ -n "$found" ]]; then
        echo "$found"
        return 0
    fi
    return 1
}

# Check files
GROUND_RULES="$(find_file "$DOCS_DIR" "ground-rules.md" 2>/dev/null || echo "")"
ARCHITECTURE="$(find_file "$DOCS_DIR" "architecture.md" 2>/dev/null || echo "")"
STANDARDS="$(find_file "$DOCS_DIR" "standards.md" 2>/dev/null || echo "")"

# Count specs
SPECS_COUNT=0
if [[ -d "$REPO_ROOT/specs" ]]; then
    SPECS_COUNT="$(find "$REPO_ROOT/specs" -name "spec.md" 2>/dev/null | wc -l | tr -d ' ')"
fi

# Make paths relative
rel_path() {
    local full="$1"
    [[ -z "$full" ]] && echo "null" && return
    echo "\"${full#"$REPO_ROOT/"}\""
}

if [[ "$JSON_OUTPUT" == true ]]; then
    cat <<ENDJSON
{
  "repo_root": "$REPO_ROOT",
  "found": {
    "ground_rules": $(rel_path "$GROUND_RULES"),
    "architecture": $(rel_path "$ARCHITECTURE"),
    "standards": $(rel_path "$STANDARDS")
  },
  "status": {
    "ground_rules_present": $([[ -n "$GROUND_RULES" ]] && echo "true" || echo "false"),
    "architecture_present": $([[ -n "$ARCHITECTURE" ]] && echo "true" || echo "false"),
    "standards_present": $([[ -n "$STANDARDS" ]] && echo "true" || echo "false"),
    "specs_count": $SPECS_COUNT
  }
}
ENDJSON
    exit 0
fi

# Human-readable output
echo "Repository root: $REPO_ROOT"
echo "Checks:"
echo " - docs/ground-rules.md: ${GROUND_RULES:-MISSING}"
echo " - docs/architecture.md: ${ARCHITECTURE:-MISSING}"
echo " - docs/standards.md: ${STANDARDS:-MISSING}"
echo " - specs/*/spec.md count: $SPECS_COUNT"

if [[ -z "$GROUND_RULES" ]]; then
    echo ""
    echo "ERROR: ground-rules.md is required. Create docs/ground-rules.md and re-run."
    exit 2
fi

exit 0
