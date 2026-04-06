#!/usr/bin/env bash
# Validate Command Script
# Validates agent command files for correctness and compliance.
#
# Usage:
#     bash validate-command.sh <path-to-command-file>
#
# Examples:
#     bash validate-command.sh .claude/commands/specify.md
#     bash validate-command.sh .gemini/commands/analyze.toml
#
# Platforms:
#     - macOS 12+
#     - Linux (Ubuntu 20.04+, Debian 11+)
#     - Windows (Git Bash, WSL)
#
# Requirements:
#     - Bash 4.0+
#     - grep, sed, wc (standard Unix tools)
#
# Exit Codes:
#     0 - All validations passed
#     1 - One or more validations failed
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

print_pass()    { printf "${GREEN}✅ PASS | %-25s %s${NC}\n" "$1" "$2"; }
print_fail()    { printf "${RED}❌ FAIL | %-25s %s${NC}\n" "$1" "$2"; }
print_warn()    { printf "${YELLOW}⚠  WARN | %-25s %s${NC}\n" "$1" "$2"; }
print_info_msg(){ printf "${BLUE}ℹ  INFO | %-25s %s${NC}\n" "$1" "$2"; }
print_header()  { printf "\n${BOLD}${MAGENTA}%s${NC}\n" "$1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <path-to-command-file>

Arguments:
    path-to-command-file    Path to a .md or .toml command file

Examples:
    $(basename "$0") .claude/commands/specify.md
    $(basename "$0") .gemini/commands/analyze.toml
EOF
}

# ── Constants ──────────────────────────────────────────────────────
MAX_DESCRIPTION_LENGTH=80
MIN_DESCRIPTION_LENGTH=10

# ── Argument parsing ────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    printf "${RED}Error: Path argument is required${NC}\n" >&2
    usage
    exit 2
fi

FILE_PATH="$1"

if [[ ! -f "$FILE_PATH" ]]; then
    printf "${RED}Error: File not found: %s${NC}\n" "$FILE_PATH" >&2
    exit 1
fi

# ── Extract frontmatter value ──────────────────────────────────────
get_frontmatter_value() {
    local content="$1"
    local key="$2"

    local frontmatter
    frontmatter=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

    echo "$frontmatter" | { grep -E "^${key}:" || true; } | head -1 | sed "s/^${key}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//'
}

# ── Validate file name ─────────────────────────────────────────────
validate_file_name() {
    local filepath="$1"
    local filename
    filename=$(basename "$filepath")
    local ext="${filename##*.}"
    local name="${filename%%.*}"

    # Check extension
    if [[ "$ext" != "md" && "$ext" != "toml" ]]; then
        print_fail "File Extension" "Invalid extension '.$ext'. Must be .md or .toml"
        return 1
    fi
    print_pass "File Extension" ".$ext"

    # Check naming convention
    if ! echo "$name" | grep -qE '^[a-z0-9]+([-.][a-z0-9]+)*$'; then
        print_warn "File Name" "Name '$name' should be lowercase with hyphens/dots"
    else
        print_pass "File Name" "'$name'"
    fi

    return 0
}

# ── Validate Markdown command ──────────────────────────────────────
validate_markdown() {
    local content="$1"
    local success=true

    # 1. Frontmatter check
    if ! echo "$content" | head -1 | grep -q '^---$'; then
        print_fail "Frontmatter" "Missing YAML frontmatter (must start with ---)"
        return 1
    fi

    # Check closing frontmatter
    local end_line
    end_line=$(echo "$content" | tail -n +2 | grep -n '^---$' | head -1 | cut -d: -f1)
    if [[ -z "$end_line" ]]; then
        print_fail "Frontmatter" "Unclosed YAML frontmatter"
        return 1
    fi
    print_pass "Frontmatter" "Valid frontmatter found"

    # 2. Description check
    local description
    description=$(get_frontmatter_value "$content" "description")
    if [[ -z "$description" ]]; then
        print_fail "Description" "Missing required field: description"
        success=false
    else
        local desc_len=${#description}
        if [[ "$desc_len" -lt "$MIN_DESCRIPTION_LENGTH" ]]; then
            print_warn "Description" "Too short ($desc_len chars < $MIN_DESCRIPTION_LENGTH)"
        elif [[ "$desc_len" -gt "$MAX_DESCRIPTION_LENGTH" ]]; then
            print_warn "Description" "Too long ($desc_len chars > $MAX_DESCRIPTION_LENGTH)"
        else
            print_pass "Description" "Valid ($desc_len chars)"
        fi
    fi

    # 3. Arguments placeholder check
    local body
    body=$(echo "$content" | tail -n +"$((end_line + 2))")
    if ! echo "$body" | grep -q '\$ARGUMENTS'; then
        print_info_msg "Arguments" "Missing '\$ARGUMENTS' placeholder. Ensure you handle inputs if needed."
    else
        print_pass "Arguments" "'\$ARGUMENTS' placeholder found"
    fi

    $success
}

# ── Validate TOML command ──────────────────────────────────────────
validate_toml() {
    local content="$1"
    local success=true

    # 1. Description check
    if ! echo "$content" | grep -qE '^description\s*='; then
        print_fail "Description" "Missing required key: description"
        success=false
    else
        local desc
        desc=$(echo "$content" | grep -E '^description\s*=' | head -1 | sed 's/^description[[:space:]]*=[[:space:]]*//' | sed 's/^["'\'']//' | sed 's/["'\'']*$//')
        local desc_len=${#desc}
        if [[ "$desc_len" -lt "$MIN_DESCRIPTION_LENGTH" ]]; then
            print_warn "Description" "Too short ($desc_len chars < $MIN_DESCRIPTION_LENGTH)"
        else
            print_pass "Description" "Valid ($desc_len chars)"
        fi
    fi

    # 2. Prompt check
    if ! echo "$content" | grep -q 'prompt'; then
        print_fail "Prompt" "Missing required key: prompt"
        success=false
    else
        print_pass "Prompt" "Prompt key found"
    fi

    # 3. Arguments placeholder check
    if ! echo "$content" | grep -q '{{args}}'; then
        print_info_msg "Arguments" "Missing '{{args}}' placeholder in TOML content"
    else
        print_pass "Arguments" "'{{args}}' placeholder found"
    fi

    $success
}

# ── Main ───────────────────────────────────────────────────────────
FILE_NAME=$(basename "$FILE_PATH")
FILE_EXT="${FILE_NAME##*.}"

print_header "Validating: $FILE_NAME"

CONTENT=$(cat "$FILE_PATH")
ERRORS=false

# File name validation
if ! validate_file_name "$FILE_PATH"; then
    ERRORS=true
fi

# Content validation based on extension
if [[ "$FILE_EXT" == "md" ]]; then
    if ! validate_markdown "$CONTENT"; then
        ERRORS=true
    fi
elif [[ "$FILE_EXT" == "toml" ]]; then
    if ! validate_toml "$CONTENT"; then
        ERRORS=true
    fi
fi

echo "──────────────────────────────────────────────────"
if $ERRORS; then
    printf "${RED}${BOLD}🚫 VALIDATION FAILED: Please fix errors shown above.${NC}\n"
    exit 1
else
    printf "${GREEN}${BOLD}✅ VALIDATION PASSED: No issues found.${NC}\n"
    exit 0
fi
