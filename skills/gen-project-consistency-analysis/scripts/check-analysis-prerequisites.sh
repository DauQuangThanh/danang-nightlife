#!/usr/bin/env bash
# check-analysis-prerequisites.sh - Detect required artifacts for project consistency analysis
#
# Usage:
#   bash scripts/check-analysis-prerequisites.sh [feature-directory] [--json]
#   bash scripts/check-analysis-prerequisites.sh --json
#   bash scripts/check-analysis-prerequisites.sh /path/to/feature --json
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
            echo "  -h, --help         Show this help"
            exit 0
            ;;
        *) FEATURE_DIR="$1"; shift ;;
    esac
done

# Resolve to absolute path
FEATURE_DIR="$(cd "$FEATURE_DIR" 2>/dev/null && pwd)" || {
    if [[ "$JSON_MODE" == true ]]; then
        echo "{\"success\":false,\"error\":\"Directory not found: $FEATURE_DIR\"}"
    else
        echo "✗ Directory not found: $FEATURE_DIR" >&2
    fi
    exit 1
}

# Find file case-insensitively in a directory
find_file() {
    local dir="$1" pattern="$2"
    local found=""
    if [[ -d "$dir" ]]; then
        found=$(find "$dir" -maxdepth 1 -iname "$pattern" -type f 2>/dev/null | head -1)
    fi
    echo "$found"
}

# Required artifacts
SPEC_FILE=$(find_file "$FEATURE_DIR" "spec.md")
DESIGN_FILE=$(find_file "$FEATURE_DIR" "design.md")
TASKS_FILE=$(find_file "$FEATURE_DIR" "tasks.md")

# Optional artifacts - check docs/ in feature dir and parent
GROUND_RULES=""
ARCHITECTURE=""
STANDARDS=""

PARENT_DIR="$(dirname "$FEATURE_DIR")"

for check_dir in "$FEATURE_DIR/docs" "$PARENT_DIR/docs" "$FEATURE_DIR/memory" "$PARENT_DIR/memory"; do
    [[ -z "$GROUND_RULES" ]] && GROUND_RULES=$(find_file "$check_dir" "ground-rules.md")
done

for check_dir in "$FEATURE_DIR/docs" "$PARENT_DIR/docs"; do
    [[ -z "$ARCHITECTURE" ]] && ARCHITECTURE=$(find_file "$check_dir" "architecture.md")
    [[ -z "$STANDARDS" ]] && STANDARDS=$(find_file "$check_dir" "standards.md")
done

# Check required
MISSING=()
[[ -z "$SPEC_FILE" ]] && MISSING+=("spec.md")
[[ -z "$DESIGN_FILE" ]] && MISSING+=("design.md")
[[ -z "$TASKS_FILE" ]] && MISSING+=("tasks.md")

SUCCESS=true
MESSAGE="All required artifacts found"
if [[ ${#MISSING[@]} -gt 0 ]]; then
    SUCCESS=false
    MESSAGE="Missing required artifacts: $(IFS=', '; echo "${MISSING[*]}")"
fi

# Count
REQUIRED_FOUND=0
[[ -n "$SPEC_FILE" ]] && ((REQUIRED_FOUND++)) || true
[[ -n "$DESIGN_FILE" ]] && ((REQUIRED_FOUND++)) || true
[[ -n "$TASKS_FILE" ]] && ((REQUIRED_FOUND++)) || true

OPTIONAL_FOUND=0
[[ -n "$GROUND_RULES" ]] && ((OPTIONAL_FOUND++)) || true
[[ -n "$ARCHITECTURE" ]] && ((OPTIONAL_FOUND++)) || true
[[ -n "$STANDARDS" ]] && ((OPTIONAL_FOUND++)) || true

TOTAL_FOUND=$((REQUIRED_FOUND + OPTIONAL_FOUND))

# Output
if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{"success":$SUCCESS,"message":"$MESSAGE","feature_dir":"$FEATURE_DIR","spec_file":"$SPEC_FILE","design_file":"$DESIGN_FILE","tasks_file":"$TASKS_FILE","ground_rules_available":$([[ -n "$GROUND_RULES" ]] && echo true || echo false),"architecture_available":$([[ -n "$ARCHITECTURE" ]] && echo true || echo false),"standards_available":$([[ -n "$STANDARDS" ]] && echo true || echo false),"total_found":$TOTAL_FOUND,"required_found":$REQUIRED_FOUND,"optional_found":$OPTIONAL_FOUND}
EOF
else
    echo ""
    echo "Project Consistency Analysis - Prerequisite Check"
    echo "=================================================="
    echo ""
    echo "Feature Directory: $FEATURE_DIR"
    echo ""
    if [[ "$SUCCESS" == true ]]; then
        echo "Status: ✓ SUCCESS"
    else
        echo "Status: ✗ INCOMPLETE"
    fi
    echo "Message: $MESSAGE"
    echo ""
    echo "Required Artifacts:"
    [[ -n "$SPEC_FILE" ]] && echo "  spec.md    : ✓ FOUND ($SPEC_FILE)" || echo "  spec.md    : ✗ MISSING"
    [[ -n "$DESIGN_FILE" ]] && echo "  design.md  : ✓ FOUND ($DESIGN_FILE)" || echo "  design.md  : ✗ MISSING"
    [[ -n "$TASKS_FILE" ]] && echo "  tasks.md   : ✓ FOUND ($TASKS_FILE)" || echo "  tasks.md   : ✗ MISSING"
    echo ""
    echo "Optional Artifacts:"
    [[ -n "$GROUND_RULES" ]] && echo "  ground-rules.md : ✓ FOUND" || echo "  ground-rules.md : - NOT FOUND"
    [[ -n "$ARCHITECTURE" ]] && echo "  architecture.md : ✓ FOUND" || echo "  architecture.md : - NOT FOUND"
    [[ -n "$STANDARDS" ]] && echo "  standards.md    : ✓ FOUND" || echo "  standards.md    : - NOT FOUND"
    echo ""
    echo "Summary: $TOTAL_FOUND found ($REQUIRED_FOUND/3 required, $OPTIONAL_FOUND/3 optional)"
    echo ""

    if [[ "$SUCCESS" == false ]]; then
        exit 1
    fi
fi
