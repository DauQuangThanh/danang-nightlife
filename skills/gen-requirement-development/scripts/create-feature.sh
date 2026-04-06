#!/usr/bin/env bash
# Create a new feature branch and spec structure.
#
# Usage: bash scripts/create-feature.sh --number N --short-name "name" "description"
#        bash scripts/create-feature.sh --json --number N --short-name "name" "description"
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+, git

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SKILL_DIR/templates"

JSON_MODE=false
NUMBER=""
SHORT_NAME=""
DESCRIPTION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --number) NUMBER="$2"; shift 2 ;;
        --short-name) SHORT_NAME="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $(basename "$0") --number N --short-name \"name\" \"description\""
            echo ""
            echo "Options:"
            echo "  --number N          Feature number (required)"
            echo "  --short-name NAME   Short name for the feature (required)"
            echo "  --json              Output results as JSON"
            echo "  -h                  Show this help"
            exit 0
            ;;
        *) DESCRIPTION="$1"; shift ;;
    esac
done

# Validate required args
if [[ -z "$NUMBER" || -z "$SHORT_NAME" || -z "$DESCRIPTION" ]]; then
    echo "Error: --number, --short-name, and description are required" >&2
    exit 2
fi

# Validate short name format
if ! echo "$SHORT_NAME" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
    echo "Error: Short name must use lowercase letters, numbers, and hyphens only" >&2
    exit 1
fi
if echo "$SHORT_NAME" | grep -q '\-\-'; then
    echo "Error: Short name cannot contain consecutive hyphens" >&2
    exit 1
fi

# Format number as zero-padded 3-digit string
FORMATTED_NUMBER=$(printf "%03d" "$NUMBER")
BRANCH_NAME="${FORMATTED_NUMBER}-${SHORT_NAME}"
SPECS_DIR="specs/${BRANCH_NAME}"
SPEC_FILE="${SPECS_DIR}/spec.md"
CHECKLIST_DIR="${SPECS_DIR}/checklists"
CHECKLIST_FILE="${CHECKLIST_DIR}/requirements.md"

info()  { [[ "$JSON_MODE" == false ]] && echo "ℹ $1"; }
ok()    { [[ "$JSON_MODE" == false ]] && echo "✓ $1"; }
err()   { echo "✗ $1" >&2; }
warn()  { [[ "$JSON_MODE" == false ]] && echo "⚠ $1" >&2; }

info "Creating feature: $BRANCH_NAME"
info "Description: $DESCRIPTION"

# Check git
if ! command -v git &>/dev/null; then
    err "git is not installed or not in PATH"; exit 1
fi
if ! git rev-parse --git-dir &>/dev/null; then
    err "Not in a git repository"; exit 1
fi

# Check for existing branch/directory with same number and short name
if git branch 2>/dev/null | grep -qE "^[* ]*0*${NUMBER}-${SHORT_NAME}$"; then
    err "Branch with number $NUMBER and short name '$SHORT_NAME' already exists"
    exit 1
fi
if git ls-remote --heads origin 2>/dev/null | grep -qE "refs/heads/0*${NUMBER}-${SHORT_NAME}$"; then
    err "Remote branch with number $NUMBER and short name '$SHORT_NAME' already exists"
    exit 1
fi
if [[ -d "specs" ]]; then
    for d in specs/*/; do
        [[ ! -d "$d" ]] && continue
        dir_name="$(basename "$d")"
        if echo "$dir_name" | grep -qE "^0*${NUMBER}-${SHORT_NAME}$"; then
            err "Specs directory with number $NUMBER and short name '$SHORT_NAME' already exists: '$dir_name'"
            exit 1
        fi
    done
fi

# Create and checkout new branch
info "Creating branch: $BRANCH_NAME"
if ! git checkout -b "$BRANCH_NAME" 2>/dev/null; then
    err "Failed to create branch '$BRANCH_NAME'"; exit 1
fi
ok "Branch created and checked out"

# Create directory structure
info "Creating directory structure"
mkdir -p "$SPECS_DIR" "$CHECKLIST_DIR"
ok "Directories created"

CURRENT_DATE="$(date +%Y-%m-%d)"

# Copy spec template
if [[ -f "$TEMPLATES_DIR/spec-template.md" ]]; then
    info "Copying spec template"
    cp "$TEMPLATES_DIR/spec-template.md" "$SPEC_FILE"
    # Replace placeholders
    sed -i.bak "s/\[Feature Name\]/$SHORT_NAME/g" "$SPEC_FILE"
    sed -i.bak "s/\[Number-ShortName\]/$BRANCH_NAME/g" "$SPEC_FILE"
    sed -i.bak "s/\[Date\]/$CURRENT_DATE/g" "$SPEC_FILE"
    rm -f "${SPEC_FILE}.bak"
    ok "Spec template created"
else
    warn "Spec template not found, creating basic spec file"
    cat > "$SPEC_FILE" <<EOF
# $SHORT_NAME

**Feature ID**: $BRANCH_NAME
**Status**: Draft
**Created**: $CURRENT_DATE

## Overview

$DESCRIPTION

## User Scenarios & Testing

[To be filled]

## Functional Requirements

[To be filled]

## Success Criteria

[To be filled]

## Assumptions

[To be filled]

## Out of Scope

[To be filled]
EOF
    ok "Basic spec file created"
fi

# Copy checklist template
if [[ -f "$TEMPLATES_DIR/checklist-template.md" ]]; then
    info "Copying checklist template"
    cp "$TEMPLATES_DIR/checklist-template.md" "$CHECKLIST_FILE"
    sed -i.bak "s/\[FEATURE NAME\]/$SHORT_NAME/g" "$CHECKLIST_FILE"
    sed -i.bak "s/\[DATE\]/$CURRENT_DATE/g" "$CHECKLIST_FILE"
    sed -i.bak "s|\[Link to spec.md\]|[spec.md](../spec.md)|g" "$CHECKLIST_FILE"
    rm -f "${CHECKLIST_FILE}.bak"
    ok "Checklist template created"
else
    warn "Checklist template not found, creating basic checklist"
    cat > "$CHECKLIST_FILE" <<EOF
# Specification Quality Checklist: $SHORT_NAME

**Feature**: [spec.md](../spec.md)
**Created**: $CURRENT_DATE

## Content Quality
- [ ] No implementation details
- [ ] Focused on user value
- [ ] All mandatory sections completed

## Requirement Completeness
- [ ] Requirements are testable
- [ ] Success criteria are measurable
- [ ] Edge cases identified

## Feature Readiness
- [ ] Ready for next phase
EOF
    ok "Basic checklist created"
fi

# Output
if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{"success":true,"branch_name":"$BRANCH_NAME","feature_number":"$FORMATTED_NUMBER","short_name":"$SHORT_NAME","description":"$DESCRIPTION","spec_file":"$SPEC_FILE","checklist_file":"$CHECKLIST_FILE","specs_dir":"$SPECS_DIR"}
EOF
else
    echo ""
    ok "Feature created successfully!"
    echo ""
    echo "Branch: $BRANCH_NAME"
    echo "Spec file: $SPEC_FILE"
    echo "Checklist: $CHECKLIST_FILE"
    echo ""
    info "Next steps:"
    echo "  1. Fill in the specification: $SPEC_FILE"
    echo "  2. Validate using checklist: $CHECKLIST_FILE"
    echo "  3. Commit your changes: git add . && git commit -m 'docs: add specification for $SHORT_NAME'"
fi
