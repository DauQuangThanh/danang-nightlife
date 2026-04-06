#!/usr/bin/env bash
# Generate Command Script
# Generates a new agent command file from templates.
#
# Usage:
#     bash generate-command.sh <command-name> --agent <agent-type> [--project <project-name>]
#
# Examples:
#     bash generate-command.sh analyze-code --agent claude
#     bash generate-command.sh specify --agent copilot --project myapp
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
NC='\033[0m'

print_success() { printf "${GREEN}✓ %s${NC}\n" "$1"; }
print_error()   { printf "${RED}✗ %s${NC}\n" "$1" >&2; }
print_info()    { printf "${BLUE}ℹ %s${NC}\n" "$1"; }
print_warning() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <command-name> --agent <agent-type> [--project <project-name>]

Arguments:
    command-name    Name of the command (lowercase, hyphens, digits only)
    --agent         Target agent platform (required)
    --project       Project name for Copilot mode field (default: project)

Supported agents:
    Markdown:  claude, cursor, windsurf, kilocode, roo, bob, jules,
               antigravity, amazonq, qoder, auggie, codebuddy, codex,
               shai, opencode, amp
    Special:   copilot
    TOML:      gemini, qwen

Examples:
    $(basename "$0") analyze-code --agent claude
    $(basename "$0") specify --agent copilot --project myapp
EOF
}

# ── Agent Configuration ────────────────────────────────────────────
# Format: "directory|extension|template"
declare -A AGENT_CONFIG
AGENT_CONFIG=(
    [claude]=".claude/commands|.md|markdown-command-template.md"
    [cursor]=".cursor/commands|.md|markdown-command-template.md"
    [windsurf]=".windsurf/workflows|.md|markdown-command-template.md"
    [kilocode]=".kilocode/rules|.md|markdown-command-template.md"
    [roo]=".roo/rules|.md|markdown-command-template.md"
    [bob]=".bob/commands|.md|markdown-command-template.md"
    [jules]=".agent|.md|markdown-command-template.md"
    [antigravity]=".agent/rules|.md|markdown-command-template.md"
    [amazonq]=".amazonq/prompts|.md|markdown-command-template.md"
    [qoder]=".qoder/commands|.md|markdown-command-template.md"
    [auggie]=".augment/rules|.md|markdown-command-template.md"
    [codebuddy]=".codebuddy/commands|.md|markdown-command-template.md"
    [codex]=".codex/commands|.md|markdown-command-template.md"
    [shai]=".shai/commands|.md|markdown-command-template.md"
    [opencode]=".opencode/command|.md|markdown-command-template.md"
    [amp]=".agents/commands|.md|markdown-command-template.md"
    [copilot]=".github/prompts|.prompt.md|copilot-command-template.md"
    [gemini]=".gemini/commands|.toml|toml-command-template.toml"
    [qwen]=".qwen/commands|.toml|toml-command-template.toml"
)

# ── Argument parsing ────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    print_error "Command name is required"
    usage
    exit 2
fi

COMMAND_NAME=""
AGENT_TYPE=""
PROJECT_NAME="project"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            AGENT_TYPE="${2:-}"
            shift 2
            ;;
        --project)
            PROJECT_NAME="${2:-project}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 2
            ;;
        *)
            COMMAND_NAME="$1"
            shift
            ;;
    esac
done

if [[ -z "$COMMAND_NAME" ]]; then
    print_error "Command name is required"
    usage
    exit 2
fi

if [[ -z "$AGENT_TYPE" ]]; then
    print_error "--agent is required"
    usage
    exit 2
fi

# ── Validate command name ──────────────────────────────────────────
if ! echo "$COMMAND_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    print_error "Command name '$COMMAND_NAME' must contain only lowercase letters, numbers, and hyphens."
    exit 1
fi

# ── Validate agent type ───────────────────────────────────────────
if [[ -z "${AGENT_CONFIG[$AGENT_TYPE]+x}" ]]; then
    print_error "Unknown agent type: $AGENT_TYPE"
    echo "Supported agents: ${!AGENT_CONFIG[*]}"
    exit 1
fi

# ── Parse agent config ─────────────────────────────────────────────
IFS='|' read -r AGENT_DIR AGENT_EXT AGENT_TEMPLATE <<< "${AGENT_CONFIG[$AGENT_TYPE]}"

# ── Resolve directories ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" 2>/dev/null && pwd)" || TEMPLATE_DIR=""

# Resolve project root (4 levels up from scripts dir: .github/skills/agent-command-creation/scripts)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." 2>/dev/null && pwd)" || PROJECT_ROOT="$(pwd)"

get_template_content() {
    local template_name="$1"

    # Try sibling templates directory first
    if [[ -n "$TEMPLATE_DIR" && -f "$TEMPLATE_DIR/$template_name" ]]; then
        cat "$TEMPLATE_DIR/$template_name"
        return 0
    fi

    # Fallback: current directory
    if [[ -f ".github/skills/agent-command-creation/templates/$template_name" ]]; then
        cat ".github/skills/agent-command-creation/templates/$template_name"
        return 0
    fi

    print_warning "Template not found: $template_name"
    return 1
}

# ── Create command ─────────────────────────────────────────────────
TARGET_DIR="$PROJECT_ROOT/$AGENT_DIR"
TARGET_FILE="$TARGET_DIR/${COMMAND_NAME}${AGENT_EXT}"

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Check if file already exists
if [[ -f "$TARGET_FILE" ]]; then
    print_error "File already exists at $TARGET_FILE"
    exit 1
fi

# Read template and process
if CONTENT=$(get_template_content "$AGENT_TEMPLATE"); then
    # Title case the command name
    TITLE_NAME=$(echo "$COMMAND_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Replace generic header
    CONTENT=$(echo "$CONTENT" | sed "s/# Command Name/# $TITLE_NAME/")

    # Copilot-specific: replace mode field
    if [[ "$AGENT_TYPE" == "copilot" ]]; then
        CONTENT=$(echo "$CONTENT" | sed "s/project\.command-name/${PROJECT_NAME}.${COMMAND_NAME}/")
    fi

    echo "$CONTENT" > "$TARGET_FILE"

    print_success "Successfully created command: $TARGET_FILE"
    print_info "Agent: $AGENT_TYPE"
    print_info "Format: $AGENT_EXT"
else
    print_error "Could not load template '$AGENT_TEMPLATE'"
    exit 1
fi
