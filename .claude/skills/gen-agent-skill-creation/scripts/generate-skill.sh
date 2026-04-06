#!/usr/bin/env bash
# Generate Skill Script
# Generates a new agent skill structure following the Agent Skills specification.
#
# Usage:
#     bash generate-skill.sh <skill-name> [output_dir]
#
# Examples:
#     bash generate-skill.sh my-new-skill
#     bash generate-skill.sh pdf-processing ./skills/
#
# Platforms:
#     - macOS 12+
#     - Linux (Ubuntu 20.04+, Debian 11+)
#     - Windows (Git Bash, WSL)
#
# Requirements:
#     - Bash 4.0+
#
# Exit Codes:
#     0 - Success
#     1 - General error
#     2 - Invalid usage/arguments

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_success() { printf "${GREEN}✓ %s${NC}\n" "$1"; }
print_error()   { printf "${RED}✗ %s${NC}\n" "$1" >&2; }
print_info()    { printf "${BLUE}ℹ %s${NC}\n" "$1"; }
print_warning() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <skill-name> [output_dir]

Arguments:
    skill-name      Name of the skill (lowercase, hyphens only, 1-64 chars)
    output_dir      Directory to create skill in (default: current directory)

Examples:
    $(basename "$0") my-new-skill
    $(basename "$0") pdf-processing ./skills/
EOF
}

# ── Argument parsing ────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    print_error "Skill name is required"
    usage
    exit 2
fi

SKILL_NAME="$1"
OUTPUT_DIR="${2:-.}"

# ── Validate skill name ────────────────────────────────────────────
validate_skill_name() {
    local name="$1"

    if [[ -z "$name" ]]; then
        print_error "Name cannot be empty"
        return 1
    fi

    if [[ ${#name} -gt 64 ]]; then
        print_error "Name too long (max 64 chars)"
        return 1
    fi

    if ! echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        print_error "Name must be lowercase, alphanumeric, hyphens only, no consecutive hyphens, no start/end hyphens"
        return 1
    fi

    return 0
}

if ! validate_skill_name "$SKILL_NAME"; then
    print_error "Invalid skill name: $SKILL_NAME"
    exit 1
fi

# ── Resolve template directory ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" 2>/dev/null && pwd)" || TEMPLATE_DIR=""

get_template_content() {
    local template_name="$1"

    # Try sibling templates directory first
    if [[ -n "$TEMPLATE_DIR" && -f "$TEMPLATE_DIR/$template_name" ]]; then
        cat "$TEMPLATE_DIR/$template_name"
        return 0
    fi

    # Fallback: current directory/templates
    if [[ -f "templates/$template_name" ]]; then
        cat "templates/$template_name"
        return 0
    fi

    print_warning "Template not found: $template_name. Using internal default."
    return 1
}

# ── Create skill ────────────────────────────────────────────────────
ROOT_PATH="$OUTPUT_DIR/$SKILL_NAME"

if [[ -d "$ROOT_PATH" ]]; then
    print_error "Directory already exists: $ROOT_PATH"
    exit 1
fi

# 1. Create directory structure
mkdir -p "$ROOT_PATH/scripts" "$ROOT_PATH/references" "$ROOT_PATH/templates" "$ROOT_PATH/assets"
print_success "Created directory structure at $ROOT_PATH"

# 2. Create SKILL.md
TODAY=$(date +%Y-%m-%d)
TITLE_NAME=$(echo "$SKILL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

if SKILL_TEMPLATE=$(get_template_content "skill-template.md"); then
    CONTENT=$(echo "$SKILL_TEMPLATE" \
        | sed "s/name: skill-name/name: $SKILL_NAME/" \
        | sed "s/# Skill Name/# $TITLE_NAME/" \
        | sed "s/last_updated: \"YYYY-MM-DD\"/last_updated: \"$TODAY\"/")
    echo "$CONTENT" > "$ROOT_PATH/SKILL.md"
    print_success "Created SKILL.md from template"
else
    cat > "$ROOT_PATH/SKILL.md" <<SKILLEOF
---
name: $SKILL_NAME
description: "[ACTION 1], [ACTION 2], and [ACTION 3]. Use when [SCENARIO 1], [SCENARIO 2], or when user mentions [KEYWORD 1], [KEYWORD 2], or [KEYWORD 3]."
license: MIT
metadata:
  author: Your Name
  version: "1.0"
  last_updated: "$TODAY"
---

# $TITLE_NAME

## Overview

[Brief 2-3 sentence explanation of what this skill does and its primary purpose]

## When to Use

- [Specific scenario 1]
- [Specific scenario 2]
- [Specific scenario 3]

## Prerequisites

**Required:**
- None

## Instructions

### Step 1: [Action Name]

[Instructions]

## Examples

### Example 1: [Use Case]

**Input:**
\`\`\`
[Input]
\`\`\`

**Output:**
\`\`\`
[Output]
\`\`\`
SKILLEOF
    print_info "Created SKILL.md (default content)"
fi

# 3. Create .gitkeep files
touch "$ROOT_PATH/references/.gitkeep" "$ROOT_PATH/templates/.gitkeep" "$ROOT_PATH/assets/.gitkeep"

# 4. Create sample scripts (Bash + PowerShell for cross-platform)
# Bash script
if BASH_TEMPLATE=$(get_template_content "script-template.sh"); then
    echo "$BASH_TEMPLATE" | sed "s/\[Script Name\]/$SKILL_NAME-script/" > "$ROOT_PATH/scripts/$SKILL_NAME.sh"
    chmod +x "$ROOT_PATH/scripts/$SKILL_NAME.sh" 2>/dev/null || true
    print_success "Created Bash script at scripts/$SKILL_NAME.sh"
fi

# PowerShell script
if PS_TEMPLATE=$(get_template_content "script-template.ps1"); then
    echo "$PS_TEMPLATE" | sed "s/\[Script Name\]/$SKILL_NAME-script/" > "$ROOT_PATH/scripts/$SKILL_NAME.ps1"
    print_success "Created PowerShell script at scripts/$SKILL_NAME.ps1"
fi

printf "\n${BOLD}Skill '%s' created successfully!${NC}\n" "$SKILL_NAME"
echo ""
echo "Next steps:"
echo "1. Edit $ROOT_PATH/SKILL.md to add description and instructions"
echo "2. Customize scripts in $ROOT_PATH/scripts/ (.sh, .ps1)"
echo "3. Validate using: bash scripts/validate-skill.sh $ROOT_PATH"
