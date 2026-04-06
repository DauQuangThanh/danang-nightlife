#!/usr/bin/env bash
# check-implementation.sh - Check implementation prerequisites for a feature directory
#
# Usage:
#   bash scripts/check-implementation.sh [feature-directory] [--json]
#
# Arguments:
#   feature-directory  Feature directory to check (default: current directory)
#   --json             Output results in JSON format
#
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

JSON_MODE=false
FEATURE_DIR="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        -h|--help)
            echo "Usage: $(basename "$0") [feature-directory] [--json]"
            echo ""
            echo "Arguments:"
            echo "  feature-directory  Feature directory to check (default: .)"
            echo "  --json             Output results in JSON format"
            exit 0
            ;;
        *) FEATURE_DIR="$1"; shift ;;
    esac
done

FEATURE_DIR="$(cd "$FEATURE_DIR" 2>/dev/null && pwd)" || {
    if [[ "$JSON_MODE" == true ]]; then
        echo "{\"error\":\"Directory not found: $FEATURE_DIR\"}"
    else
        echo "✗ Directory not found: $FEATURE_DIR" >&2
    fi
    exit 1
}

# Scan documents
AVAILABLE=()
MISSING_REQUIRED=()
TASKS_FILE=""
CHECKLIST_STATUS="no_checklists"
CHECKLIST_COUNT=0

# Required
for doc in tasks.md design.md; do
    if [[ -f "$FEATURE_DIR/$doc" ]]; then
        AVAILABLE+=("$doc")
        [[ "$doc" == "tasks.md" ]] && TASKS_FILE="$FEATURE_DIR/tasks.md"
    else
        MISSING_REQUIRED+=("$doc")
    fi
done

# Optional
for doc in spec.md data-model.md research.md; do
    [[ -f "$FEATURE_DIR/$doc" ]] && AVAILABLE+=("$doc")
done

# Product-level docs (check parent dirs up to git root)
REPO_ROOT="$FEATURE_DIR"
while [[ "$REPO_ROOT" != "/" ]]; do
    [[ -d "$REPO_ROOT/.git" ]] && break
    REPO_ROOT="$(dirname "$REPO_ROOT")"
done
[[ -f "$REPO_ROOT/docs/architecture.md" ]] && AVAILABLE+=("docs/architecture.md")
[[ -f "$REPO_ROOT/docs/standards.md" ]] && AVAILABLE+=("docs/standards.md")
[[ -f "$REPO_ROOT/docs/ground-rules.md" ]] && AVAILABLE+=("docs/ground-rules.md")

# Directories
[[ -d "$FEATURE_DIR/contracts" ]] && AVAILABLE+=("contracts/")

# Checklists
if [[ -d "$FEATURE_DIR/checklists" ]]; then
    CHECKLIST_COUNT=$(find "$FEATURE_DIR/checklists" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$CHECKLIST_COUNT" -gt 0 ]]; then
        CHECKLIST_STATUS="found"
    fi
fi

# Task count
TASK_COUNT=0
if [[ -n "$TASKS_FILE" && -f "$TASKS_FILE" ]]; then
    TASK_COUNT=$(grep -c '^\- \[ \]' "$TASKS_FILE" 2>/dev/null || echo 0)
fi

SUCCESS=true
[[ ${#MISSING_REQUIRED[@]} -gt 0 ]] && SUCCESS=false

# Output
if [[ "$JSON_MODE" == true ]]; then
    avail_json=$(printf '"%s",' "${AVAILABLE[@]}" 2>/dev/null | sed 's/,$//')
    missing_json=$(printf '"%s",' "${MISSING_REQUIRED[@]}" 2>/dev/null | sed 's/,$//')
    cat <<EOF
{"success":$SUCCESS,"feature_dir":"$FEATURE_DIR","tasks_file":"${TASKS_FILE}","available_docs":[${avail_json}],"missing_required":[${missing_json}],"task_count":$TASK_COUNT,"checklist_status":"$CHECKLIST_STATUS","checklist_count":$CHECKLIST_COUNT}
EOF
else
    echo "Implementation Check: $FEATURE_DIR"
    echo "========================================="
    echo ""
    if [[ "$SUCCESS" == true ]]; then
        echo "✓ All required documents found"
    else
        echo "✗ Missing required: $(IFS=', '; echo "${MISSING_REQUIRED[*]}")" >&2
    fi
    echo ""
    echo "Available (${#AVAILABLE[@]}):"
    for doc in "${AVAILABLE[@]}"; do echo "  - $doc"; done
    echo ""
    echo "Tasks: $TASK_COUNT"
    echo "Checklists: $CHECKLIST_STATUS ($CHECKLIST_COUNT files)"

    [[ "$SUCCESS" == false ]] && exit 1
fi
