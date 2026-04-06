#!/usr/bin/env bash
# Set up design directory structure and templates.
#
# Usage: bash scripts/setup-design.sh [--json]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+, git

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SKILL_DIR/templates"

JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--json]"
            echo ""
            echo "Options:"
            echo "  --json    Output results in JSON format"
            echo "  -h        Show this help"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument: $arg" >&2
            exit 2
            ;;
    esac
done

info()  { [[ "$JSON_MODE" == false ]] && echo "ℹ $1"; }
ok()    { [[ "$JSON_MODE" == false ]] && echo "✓ $1"; }
err()   { echo "✗ $1" >&2; }

# Check git
if ! command -v git &>/dev/null; then
    err "git is not installed or not in PATH"; exit 1
fi
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
    err "Git repository required for technical design workflow"
    err "Please initialize git repository and create a feature branch (format: N-feature-name)"
    exit 1
fi

# Get current branch
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Validate feature branch format (N-feature-name)
if ! echo "$CURRENT_BRANCH" | grep -qE '^[0-9]+-(.+)$'; then
    err "Not on a feature branch. Technical design requires a feature branch (format: N-feature-name)"
    err "Please create and checkout a feature branch first"
    exit 1
fi

info "Detected feature branch: $CURRENT_BRANCH"

FEATURE_DIR="specs/$CURRENT_BRANCH"
FEATURE_SPEC="$FEATURE_DIR/spec.md"

if [[ ! -d "$FEATURE_DIR" ]]; then
    err "Feature directory not found: $FEATURE_DIR"
    err "Please ensure specs/$CURRENT_BRANCH directory exists"
    exit 1
fi

info "Using feature-specific design directory: $FEATURE_DIR"

FEATURE_DESIGN="$FEATURE_DIR/design.md"
RESEARCH_DIR="$FEATURE_DIR/research"
RESEARCH_FILE="$RESEARCH_DIR/research.md"
DATA_MODEL_FILE="$FEATURE_DIR/data-model.md"
QUICKSTART_FILE="$FEATURE_DIR/quickstart.md"
CONTRACTS_DIR="$FEATURE_DIR/contracts"

# Create directory structure
info "Creating design directory structure"
mkdir -p "$RESEARCH_DIR" "$CONTRACTS_DIR"
ok "Directories created"

# Copy templates
if [[ -f "$TEMPLATES_DIR/design-template.md" ]]; then
    info "Copying design template"
    cp "$TEMPLATES_DIR/design-template.md" "$FEATURE_DESIGN"
    ok "Design template copied to $FEATURE_DESIGN"
else
    err "Design template not found at $TEMPLATES_DIR/design-template.md"
    exit 1
fi

if [[ -f "$TEMPLATES_DIR/research-template.md" ]]; then
    info "Copying research template"
    cp "$TEMPLATES_DIR/research-template.md" "$RESEARCH_FILE"
    ok "Research template copied to $RESEARCH_FILE"
fi

if [[ -f "$TEMPLATES_DIR/data-model-template.md" ]]; then
    info "Copying data model template"
    cp "$TEMPLATES_DIR/data-model-template.md" "$DATA_MODEL_FILE"
    ok "Data model template copied to $DATA_MODEL_FILE"
fi

if [[ -f "$TEMPLATES_DIR/api-contract-template.md" ]]; then
    info "Copying API contract template"
    cp "$TEMPLATES_DIR/api-contract-template.md" "$CONTRACTS_DIR/example-contract.md"
    ok "API contract template copied to $CONTRACTS_DIR/"
fi

# Output
if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{"success":true,"has_git":true,"current_branch":"$CURRENT_BRANCH","feature_spec":"$FEATURE_SPEC","feature_design":"$FEATURE_DESIGN","research_file":"$RESEARCH_FILE","data_model_file":"$DATA_MODEL_FILE","quickstart_file":"$QUICKSTART_FILE","contracts_dir":"$CONTRACTS_DIR","design_dir":"$FEATURE_DIR"}
EOF
else
    echo ""
    ok "Design workspace created successfully!"
    echo ""
    echo "Design directory: $FEATURE_DIR"
    echo "Design document: $FEATURE_DESIGN"
    echo "Research document: $RESEARCH_FILE"
    echo "Data model: $DATA_MODEL_FILE"
    echo "Contracts directory: $CONTRACTS_DIR"
    echo "Feature spec: $FEATURE_SPEC"
    echo ""
    info "Next steps:"
    echo "  1. Review and fill in $FEATURE_DESIGN"
    echo "  2. Conduct research and document in $RESEARCH_FILE"
    echo "  3. Design data models in $DATA_MODEL_FILE"
    echo "  4. Create API contracts in $CONTRACTS_DIR/"
fi
