#!/usr/bin/env bash
# Update agent context files with architecture reference.
#
# Usage: bash scripts/update-agent-context.sh [agent-type]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}INFO:${NC} $1"; }
log_warn()  { echo -e "${YELLOW}WARNING:${NC} $1"; }

AGENT_TYPE="${1:-}"

# Find repository root
find_repo_root() {
    local current
    current="$(pwd)"
    while [[ "$current" != "/" ]]; do
        if [[ -d "$current/.git" ]]; then
            echo "$current"
            return
        fi
        current="$(dirname "$current")"
    done
    pwd
}

ROOT_DIR="$(find_repo_root)"
ARCH_DOC="$ROOT_DIR/docs/architecture.md"
ARCH_REF=$'\n\n# Architecture Context\nPlease refer to [System Architecture](docs/architecture.md) for architectural decisions and patterns.\n'

if [[ ! -f "$ARCH_DOC" ]]; then
    log_warn "Architecture document not found at $ARCH_DOC"
    exit 0
fi

# Agent config file mapping
get_agent_file() {
    local agent="$1"
    case "$agent" in
        copilot)      echo "$ROOT_DIR/.github/copilot-instructions.md" ;;
        cursor-agent) echo "$ROOT_DIR/.cursorrules" ;;
        windsurf)     echo "$ROOT_DIR/.windsurfrules" ;;
        *)            echo "" ;;
    esac
}

update_file() {
    local agent="$1"
    local file="$2"
    if [[ ! -f "$file" ]]; then return; fi
    if grep -q "docs/architecture.md" "$file" 2>/dev/null; then
        log_info "$agent already references architecture documentation."
        return
    fi
    log_info "Updating $agent..."
    printf '%s' "$ARCH_REF" >> "$file"
    log_info "Added architecture reference to $agent"
}

AGENTS=(copilot cursor-agent windsurf)
UPDATED=0

if [[ -n "$AGENT_TYPE" ]]; then
    file="$(get_agent_file "$AGENT_TYPE")"
    if [[ -n "$file" && -f "$file" ]]; then
        update_file "$AGENT_TYPE" "$file"
        ((UPDATED++))
    fi
else
    for agent in "${AGENTS[@]}"; do
        file="$(get_agent_file "$agent")"
        if [[ -n "$file" && -f "$file" ]]; then
            update_file "$agent" "$file"
            ((UPDATED++))
        fi
    done
fi

if [[ "$UPDATED" -eq 0 ]]; then
    log_info "No agent context files required updates."
else
    log_info "Updated $UPDATED agent context file(s)."
fi
