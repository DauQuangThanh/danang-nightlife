#!/usr/bin/env bash
# add-skills.sh - Download and install a skill from a git repository
#
# Usage: add-skills.sh <repo_url> <branch> <repo_path> <skill_name> <target_dir>
#
# Arguments:
#   repo_url    - Repository URL (GitHub or Azure DevOps)
#                 GitHub:    https://github.com/owner/repo
#                 Azure DevOps: https://dev.azure.com/org/project/_git/repo
#   branch      - Git branch name (e.g., main)
#   repo_path   - Path within repo containing skills (e.g., skills)
#   skill_name  - Name of the skill to download (e.g., git-commit)
#   target_dir  - Local directory to copy the skill into
#
# Uses git sparse-checkout to download only the specific skill folder,
# avoiding recursive API calls and rate limits.

set -euo pipefail

REPO_URL="${1:?Usage: add-skills.sh <repo_url> <branch> <repo_path> <skill_name> <target_dir>}"
BRANCH="${2:?Missing branch}"
REPO_PATH="${3:?Missing repo_path}"
SKILL_NAME="${4:?Missing skill_name}"
TARGET_DIR="${5:?Missing target_dir}"

SKILL_PATH="${REPO_PATH}/${SKILL_NAME}"

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but not found. Install git and try again." >&2
    exit 1
fi

# Build authenticated repo URL based on provider (used as fallback for private repos)
AUTH_REPO_URL=""
if echo "$REPO_URL" | grep -q 'github\.com'; then
    if [ -n "${GH_TOKEN:-}" ]; then
        AUTH_REPO_URL=$(echo "$REPO_URL" | sed "s|https://github.com|https://x-access-token:${GH_TOKEN}@github.com|")
    elif [ -n "${GITHUB_TOKEN:-}" ]; then
        AUTH_REPO_URL=$(echo "$REPO_URL" | sed "s|https://github.com|https://x-access-token:${GITHUB_TOKEN}@github.com|")
    fi
elif echo "$REPO_URL" | grep -q 'dev\.azure\.com'; then
    if [ -n "${AZURE_DEVOPS_PAT:-}" ]; then
        AUTH_REPO_URL=$(echo "$REPO_URL" | sed "s|https://dev\.azure\.com|https://pat:${AZURE_DEVOPS_PAT}@dev.azure.com|")
    elif [ -n "${ADO_TOKEN:-}" ]; then
        AUTH_REPO_URL=$(echo "$REPO_URL" | sed "s|https://dev\.azure\.com|https://pat:${ADO_TOKEN}@dev.azure.com|")
    fi
fi

echo "Downloading skill: ${SKILL_NAME} from ${REPO_URL}@${BRANCH}"

# Create a temporary directory for sparse checkout
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Clone strategy: try public (no auth) first, fall back to authenticated if available
# --depth 1: only latest commit (no history)
# --filter=blob:none: skip downloading blobs until needed
# --sparse: enable sparse-checkout mode
CLONE_OK=false

# Attempt 1: clone without auth (works for public repos)
if GIT_TERMINAL_PROMPT=0 git clone --depth 1 --filter=blob:none --sparse --branch "$BRANCH" \
    "$REPO_URL" "$TEMP_DIR" --quiet 2>/dev/null; then
    CLONE_OK=true
fi

# Attempt 2: clone with auth token (for private repos)
if [ "$CLONE_OK" = false ] && [ -n "$AUTH_REPO_URL" ]; then
    rm -rf "$TEMP_DIR"
    TEMP_DIR=$(mktemp -d)
    if GIT_TERMINAL_PROMPT=0 git clone --depth 1 --filter=blob:none --sparse --branch "$BRANCH" \
        "$AUTH_REPO_URL" "$TEMP_DIR" --quiet 2>&1; then
        CLONE_OK=true
    fi
fi

if [ "$CLONE_OK" = false ]; then
    echo "Error: Failed to clone ${REPO_URL} (branch: ${BRANCH})" >&2
    [ -z "$AUTH_REPO_URL" ] && echo "Hint: If this is a private repo, set GH_TOKEN/GITHUB_TOKEN (GitHub) or AZURE_DEVOPS_PAT/ADO_TOKEN (Azure DevOps)" >&2
    exit 1
fi

# Configure sparse-checkout to fetch only the skill folder
git -C "$TEMP_DIR" sparse-checkout set "$SKILL_PATH" 2>&1 || {
    echo "Error: Failed to sparse-checkout ${SKILL_PATH}" >&2
    exit 1
}

# Verify the skill directory exists in the checkout
if [ ! -d "$TEMP_DIR/$SKILL_PATH" ]; then
    echo "Error: Skill '${SKILL_NAME}' not found at path '${SKILL_PATH}' in ${REPO_URL}" >&2
    exit 1
fi

# Create target directory and copy skill files
mkdir -p "$TARGET_DIR"
cp -a "$TEMP_DIR/$SKILL_PATH/." "$TARGET_DIR/"

# Make scripts executable
if [ -d "$TARGET_DIR/scripts" ]; then
    find "$TARGET_DIR/scripts" -type f \( -name "*.sh" -o -name "*.bash" \) -exec chmod +x {} \;
fi

echo "Installed skill: ${SKILL_NAME} -> ${TARGET_DIR}"
