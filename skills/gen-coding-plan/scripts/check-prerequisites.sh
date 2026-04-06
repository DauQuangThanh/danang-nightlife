#!/usr/bin/env bash
# check-prerequisites.sh - Check prerequisites and identify feature directory
#
# Usage:
#   bash scripts/check-prerequisites.sh [--json] [--feature-dir /path/to/feature]
#
# Arguments:
#   --json          Output results as JSON
#   --feature-dir   Specify feature directory explicitly
#
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

JSON_MODE=false
FEATURE_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --feature-dir) FEATURE_DIR="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--json] [--feature-dir /path/to/feature]"
            echo ""
            echo "Options:"
            echo "  --json          Output results as JSON"
            echo "  --feature-dir   Specify feature directory explicitly"
            echo "  -h, --help      Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

info()  { [[ "$JSON_MODE" == false ]] && echo "i $1" || true; }
ok()    { [[ "$JSON_MODE" == false ]] && echo "✓ $1" || true; }
err()   { if [[ "$JSON_MODE" == true ]]; then echo "{\"error\":\"$1\"}" >&2; else echo "✗ $1" >&2; fi; }
warn()  { [[ "$JSON_MODE" == false ]] && echo "⚠ $1" >&2 || true; }

is_feature_dir() {
    [[ -f "$1/design.md" || -f "$1/spec.md" ]]
}

find_feature_dir() {
    local cwd="$PWD"

    # Check current directory
    if is_feature_dir "$cwd"; then echo "$cwd"; return 0; fi

    # Check specs/* subdirectories
    for search_dir in "$cwd/specs" "$cwd/phoenix/specs" "$cwd/docs/specs"; do
        if [[ -d "$search_dir" ]]; then
            for subdir in "$search_dir"/*/; do
                [[ -d "$subdir" ]] && is_feature_dir "$subdir" && echo "$(cd "$subdir" && pwd)" && return 0
            done
        fi
    done

    return 1
}

# Find feature directory
if [[ -n "$FEATURE_DIR" ]]; then
    FEATURE_DIR="$(cd "$FEATURE_DIR" 2>/dev/null && pwd)" || {
        err "Directory not found: $FEATURE_DIR"; exit 1
    }
else
    FEATURE_DIR=$(find_feature_dir) || {
        if [[ "$JSON_MODE" == true ]]; then
            echo "{\"success\":false,\"error\":\"No feature directory found\",\"message\":\"Could not find directory containing design.md or spec.md\"}"
        else
            err "No feature directory found"
            echo "Could not find directory containing design.md or spec.md"
            echo "Searched: $PWD, $PWD/specs/*, $PWD/phoenix/specs/*, $PWD/docs/specs/*"
        fi
        exit 1
    }
fi

# Scan documents
AVAILABLE=()
MISSING_REQUIRED=()

for doc in design.md spec.md; do
    if [[ -f "$FEATURE_DIR/$doc" ]]; then
        AVAILABLE+=("$doc")
    else
        MISSING_REQUIRED+=("$doc")
    fi
done

for doc in data-model.md research.md quickstart.md architecture.md; do
    [[ -f "$FEATURE_DIR/$doc" ]] && AVAILABLE+=("$doc")
done

if [[ -d "$FEATURE_DIR/contracts" ]]; then
    count=$(find "$FEATURE_DIR/contracts" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] && AVAILABLE+=("contracts/ ($count files)")
fi

# Check product-level docs
REPO_ROOT="$FEATURE_DIR"
while [[ "$REPO_ROOT" != "/" ]]; do
    [[ -d "$REPO_ROOT/.git" ]] && break
    REPO_ROOT="$(dirname "$REPO_ROOT")"
done
[[ -f "$REPO_ROOT/docs/architecture.md" ]] && AVAILABLE+=("docs/architecture.md")
[[ -f "$REPO_ROOT/docs/ground-rules.md" ]] && AVAILABLE+=("docs/ground-rules.md")

# Output
if [[ "$JSON_MODE" == true ]]; then
    avail_json=$(printf '"%s",' "${AVAILABLE[@]}" 2>/dev/null | sed 's/,$//')
    missing_json=$(printf '"%s",' "${MISSING_REQUIRED[@]}" 2>/dev/null | sed 's/,$//')
    warning=""
    [[ ${#MISSING_REQUIRED[@]} -gt 0 ]] && warning="Missing required: $(IFS=', '; echo "${MISSING_REQUIRED[*]}")"
    cat <<EOF
{"success":true,"feature_dir":"$FEATURE_DIR","available_docs":[${avail_json}],"missing_required":[${missing_json}]${warning:+,"warning":"$warning"}}
EOF
else
    ok "Feature directory: $FEATURE_DIR"
    echo ""
    ok "Available documents (${#AVAILABLE[@]}):"
    for doc in "${AVAILABLE[@]}"; do echo "  - $doc"; done

    if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
        echo ""
        warn "Missing required documents:"
        for doc in "${MISSING_REQUIRED[@]}"; do echo "  - $doc"; done
        exit 1
    fi
fi
