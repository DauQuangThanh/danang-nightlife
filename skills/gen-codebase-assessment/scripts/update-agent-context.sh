#!/usr/bin/env bash
# Update agent context files with assessment findings.
#
# Usage: bash scripts/update-agent-context.sh [agent-type]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}INFO:${NC} $1"; }
log_warn()  { echo -e "${YELLOW}WARNING:${NC} $1"; }
log_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

# Parse arguments
AGENT_TYPE=""
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            echo "Usage: $(basename "$0") [agent-type]"
            echo ""
            echo "Arguments:"
            echo "  agent-type   Specific agent to update (optional, updates all if omitted)"
            echo ""
            echo "Supported agents:"
            echo "  claude, gemini, copilot, cursor-agent, qwen, opencode, codex,"
            echo "  windsurf, kilocode, auggie, roo, codebuddy, amp, shai, q,"
            echo "  bob, jules, qoder, antigravity"
            exit 0
            ;;
        *)
            AGENT_TYPE="$arg"
            ;;
    esac
done

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

REPO_ROOT="$(find_repo_root)"
CONTEXT_ASSESSMENT="$REPO_ROOT/docs/context-assessment.md"
START_MARKER="<!-- CONTEXT_ASSESSMENT_START -->"
END_MARKER="<!-- CONTEXT_ASSESSMENT_END -->"

# Validate assessment file exists
if [[ ! -f "$CONTEXT_ASSESSMENT" ]]; then
    log_error "Context assessment not found at $CONTEXT_ASSESSMENT"
    log_info "Run setup-context-assessment.sh first"
    exit 1
fi

# Get agent file path for a given agent type
get_agent_file() {
    local agent="$1"
    case "$agent" in
        claude)         echo "$REPO_ROOT/CLAUDE.md" ;;
        gemini)         echo "$REPO_ROOT/GEMINI.md" ;;
        copilot)        echo "$REPO_ROOT/.github/agents/copilot-instructions.md" ;;
        cursor-agent)   echo "$REPO_ROOT/.cursor/rules/agent-rules.mdc" ;;
        qwen)           echo "$REPO_ROOT/QWEN.md" ;;
        opencode|codex|amp|q|bob|jules|antigravity)
                        echo "$REPO_ROOT/AGENTS.md" ;;
        windsurf)       echo "$REPO_ROOT/.windsurf/rules/agent-rules.md" ;;
        kilocode)       echo "$REPO_ROOT/.kilocode/rules/agent-rules.md" ;;
        auggie)         echo "$REPO_ROOT/.augment/rules/agent-rules.md" ;;
        roo)            echo "$REPO_ROOT/.roo/rules/agent-rules.md" ;;
        codebuddy)      echo "$REPO_ROOT/CODEBUDDY.md" ;;
        shai)           echo "$REPO_ROOT/SHAI.md" ;;
        qoder)          echo "$REPO_ROOT/QODER.md" ;;
        *)              echo "" ;;
    esac
}

# Extract summary from assessment file
extract_summary() {
    local today
    today="$(date +%Y-%m-%d)"

    # Extract technical health score
    local score=""
    score=$(grep -oP '\*\*Technical Health Score\*\*: \K\d+' "$CONTEXT_ASSESSMENT" 2>/dev/null || true)

    # Extract key findings (first 3 bullet points after **Key Findings**:)
    local findings=""
    findings=$(awk '/^\*\*Key Findings\*\*:/{found=1; next} found && /^- /{gsub(/^- /,"  • "); print; count++; if(count>=3) exit} found && /^\*\*/{exit}' "$CONTEXT_ASSESSMENT" 2>/dev/null || true)

    echo "## Context Assessment Summary"
    echo ""
    echo "**Assessment Date**: $today"
    if [[ -n "$score" ]]; then
        echo "**Technical Health Score**: $score/100"
    fi
    echo ""
    if [[ -n "$findings" ]]; then
        echo "**Key Findings**:"
        echo "$findings"
    fi
    echo ""
    echo "**Full Assessment**: See \`docs/context-assessment.md\`"
    echo ""
}

# Update a single agent file
update_agent_file() {
    local agent_key="$1"
    local agent_file="$2"
    local summary="$3"

    if [[ ! -f "$agent_file" ]]; then
        log_warn "Agent file not found: $agent_file (skipping $agent_key)"
        return
    fi

    log_info "Updating $agent_key context at $agent_file"

    if grep -qF "$START_MARKER" "$agent_file"; then
        # Update existing section - remove content between markers and insert new
        local tmp_file
        tmp_file="$(mktemp)"
        awk -v start="$START_MARKER" -v end="$END_MARKER" -v summary="$summary" '
            $0 ~ start { print; printf "%s\n", summary; skip=1; next }
            $0 ~ end   { skip=0; next }
            !skip       { print }
        ' "$agent_file" > "$tmp_file"
        mv "$tmp_file" "$agent_file"
    else
        # Append new section
        printf '\n\n%s\n%s\n%s\n' "$START_MARKER" "$summary" "$END_MARKER" >> "$agent_file"
    fi

    log_info "✓ Updated context assessment section in $agent_key"
}

# Build summary once
SUMMARY="$(extract_summary)"

SUPPORTED_AGENTS=(claude gemini copilot cursor-agent qwen opencode codex windsurf kilocode auggie roo codebuddy amp shai q bob jules qoder antigravity)

if [[ -n "$AGENT_TYPE" ]]; then
    # Update specific agent
    AGENT_TYPE="${AGENT_TYPE,,}"  # lowercase
    agent_file="$(get_agent_file "$AGENT_TYPE")"
    if [[ -z "$agent_file" ]]; then
        log_error "Unknown agent type: $AGENT_TYPE"
        log_info "Supported agents: ${SUPPORTED_AGENTS[*]}"
        exit 1
    fi
    update_agent_file "$AGENT_TYPE" "$agent_file" "$SUMMARY"
else
    # Update all existing agent files
    updated=0
    for agent_key in "${SUPPORTED_AGENTS[@]}"; do
        agent_file="$(get_agent_file "$agent_key")"
        if [[ -n "$agent_file" && -f "$agent_file" ]]; then
            update_agent_file "$agent_key" "$agent_file" "$SUMMARY"
            ((updated++))
        fi
    done

    if [[ "$updated" -eq 0 ]]; then
        log_warn "No agent files found in repository"
        log_info "Create an agent file first, then run this script"
    else
        log_info "✓ Updated $updated agent file(s)"
    fi
fi

log_info "✓ Agent context update complete"
