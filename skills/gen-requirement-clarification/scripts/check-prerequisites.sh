#!/usr/bin/env bash
# check-prerequisites.sh - Locate feature specification file
#
# Usage:
#   bash scripts/check-prerequisites.sh --json --paths-only
#   bash scripts/check-prerequisites.sh
#
# Arguments:
#   --json         Output results in JSON format
#   --paths-only   Only return path information (no validation)
#
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+, git (optional)

set -euo pipefail

JSON_MODE=false
PATHS_ONLY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --paths-only) PATHS_ONLY=true; shift ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--json] [--paths-only]"
            echo ""
            echo "Options:"
            echo "  --json         Output results in JSON format"
            echo "  --paths-only   Only return path information (no validation)"
            echo "  -h, --help     Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

info()    { [[ "$PATHS_ONLY" == false && "$JSON_MODE" == false ]] && echo "i $1" || true; }
ok()      { [[ "$PATHS_ONLY" == false && "$JSON_MODE" == false ]] && echo "✓ $1" || true; }
err()     { if [[ "$JSON_MODE" == true ]]; then echo "{\"error\":\"$1\"}" >&2; else echo "✗ $1" >&2; fi; }
warn()    { [[ "$PATHS_ONLY" == false && "$JSON_MODE" == false ]] && echo "⚠ $1" >&2 || true; }

HAS_GIT=false
CURRENT_BRANCH="main"
FEATURE_DIR=""
FEATURE_SPEC=""
FEATURE_DESIGN=""
TASKS=""
SPEC_EXISTS=false

# Detect git
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
    HAS_GIT=true
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

    # Check feature branch format: N-feature-name
    if [[ "$CURRENT_BRANCH" =~ ^[0-9]+-(.+)$ ]]; then
        FEATURE_DIR="specs/${CURRENT_BRANCH}"
        if [[ -d "$FEATURE_DIR" ]]; then
            FEATURE_SPEC="${FEATURE_DIR}/spec.md"
            FEATURE_DESIGN="${FEATURE_DIR}/design.md"
            TASKS="${FEATURE_DIR}/tasks.md"
            info "Detected feature branch: $CURRENT_BRANCH"
            info "Feature directory: $FEATURE_DIR"
        else
            warn "Feature branch detected but directory not found: $FEATURE_DIR"
        fi
    else
        warn "Not on a feature branch (expected format: N-feature-name)"
        warn "Current branch: $CURRENT_BRANCH"
    fi
else
    warn "Not in a git repository or git not available"
fi

# Check spec exists
if [[ -n "$FEATURE_SPEC" && -f "$FEATURE_SPEC" ]]; then
    SPEC_EXISTS=true
    ok "Spec file found: $FEATURE_SPEC"
else
    err "Spec file not found"
    [[ -n "$FEATURE_SPEC" ]] && info "Expected at: $FEATURE_SPEC"
    info "Please create a spec first using requirements-specification skill"
fi

# Output
if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{"has_git":$HAS_GIT,"current_branch":"$CURRENT_BRANCH","feature_dir":"$FEATURE_DIR","feature_spec":"$FEATURE_SPEC","feature_design":"$FEATURE_DESIGN","tasks":"$TASKS","spec_exists":$SPEC_EXISTS}
EOF
else
    echo ""
    if [[ "$SPEC_EXISTS" == true ]]; then
        ok "Prerequisites check passed"
    else
        err "Prerequisites check failed: Spec file not found"
    fi
    echo ""
    echo "Git available: $HAS_GIT"
    echo "Current branch: $CURRENT_BRANCH"
    echo "Feature directory: ${FEATURE_DIR:-N/A}"
    echo "Spec file: ${FEATURE_SPEC:-N/A}"
    echo "Spec exists: $SPEC_EXISTS"
    echo ""
    if [[ "$SPEC_EXISTS" == false ]]; then
        info "To create a spec, use the requirements-specification skill"
        exit 1
    fi
fi
