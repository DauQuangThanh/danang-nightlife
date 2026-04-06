#!/usr/bin/env bash
# Validate Skill Script
# Validates an agent skill against the Agent Skills specification.
#
# Usage:
#     bash validate-skill.sh <skill-path>
#
# Examples:
#     bash validate-skill.sh ./my-skill
#     bash validate-skill.sh ./skills/pdf-processing
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
print_header()  { printf "\n${BOLD}${MAGENTA}%s${NC}\n" "$1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <skill-path>

Arguments:
    skill-path      Path to skill directory or directory containing multiple skills

Examples:
    $(basename "$0") ./my-skill
    $(basename "$0") ./skills/
EOF
}

# ── Argument parsing ────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    printf "${RED}Error: Path argument is required${NC}\n" >&2
    usage
    exit 1
fi

TARGET_PATH="$1"

if [[ ! -d "$TARGET_PATH" ]]; then
    printf "${RED}Error: Path not found: %s${NC}\n" "$TARGET_PATH" >&2
    exit 1
fi

# ── Extract frontmatter value (simple YAML parser) ──────────────────
# Usage: get_frontmatter_value "$content" "name"
get_frontmatter_value() {
    local content="$1"
    local key="$2"

    # Extract frontmatter block between --- markers
    local frontmatter
    frontmatter=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

    # Get top-level key value (not indented)
    echo "$frontmatter" | { grep -E "^${key}:" || true; } | head -1 | sed "s/^${key}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//'
}

# ── Get nested metadata value ───────────────────────────────────────
get_metadata_value() {
    local content="$1"
    local key="$2"

    local frontmatter
    frontmatter=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

    echo "$frontmatter" | { grep -E "^[[:space:]]+${key}:" || true; } | head -1 | sed "s/^[[:space:]]*${key}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//'
}

# ── Validate a single skill ────────────────────────────────────────
validate_skill() {
    local skill_path="$1"
    local skill_name
    skill_name=$(basename "$skill_path")
    local success=true

    print_header "Validating Skill: $skill_name"
    echo "Path: $(cd "$skill_path" && pwd)"

    local skill_md="$skill_path/SKILL.md"

    # 1. Structure check
    if [[ ! -f "$skill_md" ]]; then
        print_fail "Structure Check" "SKILL.md missing"
        echo "──────────────────────────────────────────────────"
        return 1
    fi
    print_pass "Structure Check" "Structure OK"

    # Read content
    local content line_count
    content=$(cat "$skill_md")
    line_count=$(wc -l < "$skill_md" | tr -d ' ')

    # 2. Size validation
    if [[ "$line_count" -gt 500 ]]; then
        print_fail "SKILL.md Size" "$line_count lines (> 500 limit). Move details to references/."
        success=false
    else
        print_pass "SKILL.md Size" "$line_count lines"
    fi

    # 3. Frontmatter check
    if ! echo "$content" | head -1 | grep -q '^---$'; then
        print_fail "Frontmatter" "No frontmatter found (must start with ---)"
        success=false
    else
        print_pass "Frontmatter" "Valid frontmatter found"

        # Name validation
        local name
        name=$(get_frontmatter_value "$content" "name")
        if [[ -z "$name" ]]; then
            print_fail "Meta: 'name'" "Missing required field"
            success=false
        elif ! echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
            print_fail "Meta: 'name'" "Invalid format '$name'. Use lowercase, hyphens only."
            success=false
        elif [[ "$name" != "$skill_name" ]]; then
            print_fail "Meta: 'name'" "Mismatch: '$name' != dir '$skill_name'"
            success=false
        else
            print_pass "Meta: 'name'" "'$name'"
        fi

        # Description validation
        local description
        description=$(get_frontmatter_value "$content" "description")
        if [[ -z "$description" ]]; then
            print_fail "Meta: 'description'" "Missing required field"
            success=false
        else
            local desc_len=${#description}
            if [[ "$desc_len" -gt 1024 ]]; then
                print_fail "Meta: 'description'" "Too long ($desc_len chars > 1024)"
                success=false
            elif [[ "$desc_len" -lt 10 ]]; then
                print_fail "Meta: 'description'" "Too short (< 10 chars)"
                success=false
            else
                local quality_issues=""
                if ! echo "$description" | grep -qi "Use when\|Use for"; then
                    quality_issues="Missing 'Use when...' clause"
                fi
                if ! echo "$description" | grep -qi "mention\|keyword"; then
                    [[ -n "$quality_issues" ]] && quality_issues="$quality_issues, "
                    quality_issues="${quality_issues}Missing 'user mentions...' clause"
                fi
                if echo "$description" | grep -qi "helps with\|tool for\|does stuff"; then
                    [[ -n "$quality_issues" ]] && quality_issues="$quality_issues, "
                    quality_issues="${quality_issues}Contains vague term"
                fi

                if [[ -n "$quality_issues" ]]; then
                    print_pass "Meta: 'description'" "Valid but weak: $quality_issues"
                else
                    print_pass "Meta: 'description'" "Follows best practices"
                fi
            fi
        fi

        # Last updated validation
        local last_updated
        last_updated=$(get_metadata_value "$content" "last_updated")
        if [[ -n "$last_updated" ]]; then
            if ! echo "$last_updated" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
                print_fail "Meta: 'last_updated'" "Invalid date $last_updated. Use YYYY-MM-DD."
                success=false
            fi
        fi
    fi

    # 4. File reference validation
    local broken_links=""
    local broken_count=0
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        # Skip external links, anchors, absolute paths
        echo "$link" | grep -qE '^(http|#|/|mailto:)' && continue
        # Clean anchor/query params
        local clean_link
        clean_link=$(echo "$link" | cut -d'#' -f1 | cut -d'?' -f1)
        [[ -z "$clean_link" ]] && continue
        if [[ ! -e "$skill_path/$clean_link" ]]; then
            broken_count=$((broken_count + 1))
            if [[ $broken_count -le 3 ]]; then
                [[ -n "$broken_links" ]] && broken_links="$broken_links, "
                broken_links="$broken_links$clean_link"
            fi
        fi
    done < <(grep -oE '\[.*?\]\((.*?)\)' "$skill_md" | sed 's/.*](//' | sed 's/)$//' || true)

    if [[ $broken_count -gt 0 ]]; then
        local suffix=""
        [[ $broken_count -gt 3 ]] && suffix="..."
        print_fail "File References" "Broken links: $broken_links$suffix"
        success=false
    else
        print_pass "File References" "All internal links valid"
    fi

    # 5. Script validation
    local scripts_dir="$skill_path/scripts"
    if [[ -d "$scripts_dir" ]]; then
        local script_issues=""
        local banned_files=""
        for script in "$scripts_dir"/*; do
            [[ ! -f "$script" ]] && continue
            local script_name
            script_name=$(basename "$script")
            [[ "$script_name" == .* ]] && continue

            # Check for banned script formats (only .sh and .ps1 allowed)
            case "$script_name" in
                *.py|*.rb|*.js|*.ts|*.pl|*.php|*.lua)
                    [[ -n "$banned_files" ]] && banned_files="$banned_files, "
                    banned_files="${banned_files}${script_name}"
                    ;;
            esac

            # Check executable permission for .sh files on POSIX
            if [[ "$script_name" == *.sh && "$(uname)" != "MINGW"* ]]; then
                if [[ ! -x "$script" ]]; then
                    if head -1 "$script" | grep -q '^#!'; then
                        [[ -n "$script_issues" ]] && script_issues="$script_issues, "
                        script_issues="${script_issues}${script_name} has shebang but not executable"
                    fi
                fi
            fi
        done

        if [[ -n "$banned_files" ]]; then
            print_fail "Scripts Check" "Banned formats (only .sh/.ps1 allowed): $banned_files"
            success=false
        elif [[ -n "$script_issues" ]]; then
            print_fail "Scripts Check" "Issues: $script_issues"
        else
            print_pass "Scripts Check" "Scripts look compatible"
        fi
    fi

    echo "──────────────────────────────────────────────────"
    if $success; then
        printf "${GREEN}${BOLD}✅ SKILL VALID${NC}\n"
    else
        printf "${RED}${BOLD}🚫 SKILL INVALID: Please fix errors shown in red above.${NC}\n"
    fi

    $success
}

# ── Main logic ──────────────────────────────────────────────────────
if [[ -f "$TARGET_PATH/SKILL.md" ]]; then
    # Single skill mode
    validate_skill "$TARGET_PATH"
    exit $?
else
    # Directory mode - check subdirectories
    echo "Scanning directory: $TARGET_PATH"
    FAILURES=0
    TOTAL=0

    for item in "$TARGET_PATH"/*/; do
        [[ ! -d "$item" ]] && continue
        dir_name=$(basename "$item")
        [[ "$dir_name" == .* ]] && continue
        if [[ -f "$item/SKILL.md" ]]; then
            TOTAL=$((TOTAL + 1))
            if ! validate_skill "$item"; then
                FAILURES=$((FAILURES + 1))
            fi
        fi
    done

    if [[ $TOTAL -eq 0 ]]; then
        echo "No skills found (folders with SKILL.md)"
        exit 1
    fi

    echo ""
    echo "Summary:"
    echo "Total Skills: $TOTAL"
    echo "Passed:       $((TOTAL - FAILURES))"
    echo "Failed:       $FAILURES"

    [[ $FAILURES -gt 0 ]] && exit 1
    exit 0
fi
