#!/usr/bin/env bash
# Scans a project directory and outputs a JSON-like summary of its structure,
# technologies, agents, and skills for use by gen-update-agent-file.
# Usage: bash scripts/scan-project.sh [project-root]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

PROJECT_ROOT="${1:-.}"

if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "Error: Directory not found: $PROJECT_ROOT" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

echo "=== PROJECT SCAN REPORT ==="
echo "Root: $(pwd)"
echo ""

# --- 1. Project Identity ---
echo "--- PROJECT IDENTITY ---"
for f in package.json pyproject.toml Cargo.toml go.mod pom.xml *.csproj composer.json Gemfile; do
    if [[ -f "$f" ]]; then
        echo "Dependency file: $f"
    fi
done
echo ""

# --- 2. Directory Structure (max 3 levels, excluding noise) ---
echo "--- DIRECTORY STRUCTURE ---"
if command -v tree &>/dev/null; then
    tree -L 3 -d --noreport -I 'node_modules|.git|__pycache__|.venv|.next|dist|build|target|.cache|.DS_Store' 2>/dev/null || true
else
    find . -maxdepth 3 -type d \
        ! -path '*/node_modules/*' \
        ! -path '*/.git/*' \
        ! -path '*/__pycache__/*' \
        ! -path '*/.venv/*' \
        ! -path '*/.next/*' \
        ! -path '*/dist/*' \
        ! -path '*/build/*' \
        ! -path '*/target/*' \
        ! -path '*/.cache/*' \
        | sort
fi
echo ""

# --- 3. Technology Detection ---
echo "--- TECHNOLOGIES ---"

# Language detection by file extension
echo "Languages detected:"
for ext in py ts tsx js jsx rs go java kt cs rb php; do
    count=$(find . -name "*.${ext}" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.venv/*' 2>/dev/null | head -50 | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
        echo "  .${ext}: ${count} files"
    fi
done

# Config files
echo "Config files:"
for f in tsconfig.json tailwind.config.js tailwind.config.ts .eslintrc.js .eslintrc.json eslint.config.js \
         Dockerfile docker-compose.yml docker-compose.yaml .env.example \
         vite.config.ts vite.config.js webpack.config.js next.config.js next.config.ts \
         nuxt.config.ts angular.json vue.config.js \
         .markdownlint-cli2.jsonc .prettierrc .editorconfig; do
    if [[ -f "$f" ]]; then
        echo "  $f"
    fi
done
echo ""

# --- 4. Agent Ecosystem ---
echo "--- AGENTS ---"
for dir in agents .claude/agents .github/agents .cursor/agents; do
    if [[ -d "$dir" ]]; then
        echo "Agent directory: $dir/"
        find "$dir" -name '*.md' -not -name 'README.md' 2>/dev/null | while read -r agent_file; do
            name=$(grep -m1 '^name:' "$agent_file" 2>/dev/null | sed 's/^name:\s*//' || basename "$agent_file" .md)
            desc=$(grep -m1 '^description:' "$agent_file" 2>/dev/null | sed 's/^description:\s*//' || echo "No description")
            echo "  Agent: $name — $desc"
        done
    fi
done
echo ""

echo "--- SKILLS ---"
for dir in skills .claude/skills .github/skills .cursor/skills; do
    if [[ -d "$dir" ]]; then
        echo "Skills directory: $dir/"
        find "$dir" -maxdepth 2 -name 'SKILL.md' 2>/dev/null | while read -r skill_file; do
            skill_dir=$(dirname "$skill_file")
            skill_name=$(basename "$skill_dir")
            desc=$(grep -m1 '^description:' "$skill_file" 2>/dev/null | sed 's/^description:\s*["'"'"']\?//' | sed 's/["'"'"']\?$//' || echo "No description")
            echo "  Skill: $skill_name — ${desc:0:120}"
        done
    fi
done
echo ""

# --- 5. CI/CD ---
echo "--- CI/CD ---"
if [[ -d ".github/workflows" ]]; then
    echo "GitHub Actions workflows:"
    find .github/workflows -name '*.yml' -o -name '*.yaml' 2>/dev/null | while read -r wf; do
        echo "  $(basename "$wf")"
    done
fi
if [[ -f "CODEOWNERS" ]] || [[ -f ".github/CODEOWNERS" ]]; then
    echo "CODEOWNERS: present"
fi
echo ""

# --- 6. Existing Agent Files ---
echo "--- EXISTING AGENT FILES ---"
for f in CLAUDE.md AGENTS.md; do
    if [[ -f "$f" ]]; then
        echo "$f: exists ($(wc -l < "$f" | tr -d ' ') lines)"
        if grep -q '<!-- TEMPLATE' "$f" 2>/dev/null; then
            echo "  Mode: TEMPLATE (contains template markers)"
        elif grep -q '{{' "$f" 2>/dev/null; then
            echo "  Mode: TEMPLATE (contains placeholders)"
        else
            echo "  Mode: FREEFORM"
        fi
    else
        echo "$f: NOT FOUND"
    fi
done

echo ""
echo "--- TEMPLATES ---"
for f in templates/agent-file-template.md templates/AI-Agents-Configs.md; do
    if [[ -f "$f" ]]; then
        echo "Template found: $f"
    fi
done
echo ""

# --- 7. Recent Git History ---
echo "--- RECENT COMMITS ---"
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
    git log --oneline -10 2>/dev/null || echo "  (no git history)"
else
    echo "  (not a git repository)"
fi
echo ""

echo "=== SCAN COMPLETE ==="
