#!/usr/bin/env bash
# Nuxt.js Mockup Prerequisites Checker
# Verifies Node.js, package manager, and existing project detection.
#
# Usage: bash scripts/check-nuxt-prerequisites.sh [--json]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

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

NODE_AVAILABLE=false
NODE_VERSION=""
NODE_MAJOR=0
PKG_MANAGER=""
PKG_VERSION=""
PNPM_VERSION=""
YARN_VERSION=""
NPM_VERSION=""
NUXT_PROJECT=false
ALL_OK=true
ERRORS=()

# Find workspace root
WORKSPACE_ROOT="$(pwd)"
current="$(pwd)"
while [[ "$current" != "/" ]]; do
    if [[ -d "$current/.git" ]]; then
        WORKSPACE_ROOT="$current"
        break
    fi
    current="$(dirname "$current")"
done

# Check Node.js
if command -v node &>/dev/null; then
    NODE_AVAILABLE=true
    NODE_VERSION="$(node --version | sed 's/^v//')"
    NODE_MAJOR="${NODE_VERSION%%.*}"
    if [[ "$NODE_MAJOR" -lt 18 ]]; then
        ALL_OK=false
        ERRORS+=("Node.js version $NODE_VERSION is too old. Nuxt 4 requires Node.js 18.0.0 or higher")
    fi
else
    ALL_OK=false
    ERRORS+=("Node.js not found. Install from https://nodejs.org/ (v20+ recommended)")
fi

# Check package managers (pnpm preferred, then yarn, then npm)
if command -v pnpm &>/dev/null; then
    PNPM_VERSION="$(pnpm --version)"
    if [[ -z "$PKG_MANAGER" ]]; then
        PKG_MANAGER="pnpm"
        PKG_VERSION="$PNPM_VERSION"
    fi
fi

if command -v yarn &>/dev/null; then
    YARN_VERSION="$(yarn --version)"
    if [[ -z "$PKG_MANAGER" ]]; then
        PKG_MANAGER="yarn"
        PKG_VERSION="$YARN_VERSION"
    fi
fi

if command -v npm &>/dev/null; then
    NPM_VERSION="$(npm --version)"
    if [[ -z "$PKG_MANAGER" ]]; then
        PKG_MANAGER="npm"
        PKG_VERSION="$NPM_VERSION"
    fi
fi

if [[ -z "$PKG_MANAGER" ]]; then
    ALL_OK=false
    ERRORS+=("No package manager found. npm should be bundled with Node.js")
fi

# Check for existing Nuxt project
if [[ -f "$WORKSPACE_ROOT/package.json" ]]; then
    if grep -q '"nuxt"' "$WORKSPACE_ROOT/package.json" 2>/dev/null; then
        NUXT_PROJECT=true
    fi
fi

# Output
if [[ "$JSON_MODE" == true ]]; then
    # Build errors JSON array
    ERRORS_JSON="["
    for i in "${!ERRORS[@]}"; do
        [[ $i -gt 0 ]] && ERRORS_JSON+=","
        ERRORS_JSON+="\"${ERRORS[$i]}\""
    done
    ERRORS_JSON+="]"

    cat <<EOF
{"success":$ALL_OK,"workspace_root":"$WORKSPACE_ROOT","node":{"available":$NODE_AVAILABLE,"version":"$NODE_VERSION","major_version":$NODE_MAJOR},"package_manager":{"name":"$PKG_MANAGER","version":"$PKG_VERSION","npm_version":"$NPM_VERSION","pnpm_version":"$PNPM_VERSION","yarn_version":"$YARN_VERSION"},"project":{"is_nuxt":$NUXT_PROJECT},"errors":$ERRORS_JSON}
EOF
else
    echo ""
    echo "Nuxt.js Mockup - Prerequisites Check"
    echo "=================================================="
    echo ""
    echo "Workspace: $WORKSPACE_ROOT"
    echo ""

    # Node.js
    echo "Node.js:"
    if [[ "$NODE_AVAILABLE" == true ]]; then
        echo "  ✓ Node.js installed (v$NODE_VERSION)"
        if [[ "$NODE_MAJOR" -ge 18 ]]; then
            echo "  ✓ Version meets requirements (18+)"
        else
            echo "  ✗ Version too old (need 18+, have $NODE_MAJOR)"
        fi
    else
        echo "  ✗ Node.js not found (REQUIRED)"
    fi
    echo ""

    # Package Manager
    echo "Package Manager:"
    if [[ -n "$PKG_MANAGER" ]]; then
        echo "  ✓ $PKG_MANAGER v$PKG_VERSION detected"
        [[ -n "$PNPM_VERSION" ]] && echo "  ✓ pnpm available (recommended)"
        [[ -n "$YARN_VERSION" && "$PKG_MANAGER" != "yarn" ]] && echo "    yarn v$YARN_VERSION also available"
        [[ -n "$NPM_VERSION" && "$PKG_MANAGER" != "npm" ]] && echo "    npm v$NPM_VERSION also available"
    else
        echo "  ✗ No package manager found (REQUIRED)"
    fi
    echo ""

    # Project status
    echo "Project Status:"
    if [[ "$NUXT_PROJECT" == true ]]; then
        echo "  ✓ Existing Nuxt project detected"
    else
        echo "    No Nuxt project detected (will initialize new project)"
    fi
    echo ""

    # Summary
    if [[ "$ALL_OK" == true ]]; then
        echo "✓ All prerequisites met. Ready to create Nuxt mockups!"
        echo ""
        echo "Next steps:"
        echo "  1. Run skill to create mockup project"
        echo "  2. Or manually initialize: $PKG_MANAGER create nuxt@latest mockup"
        echo "  3. Install dependencies: cd mockup && $PKG_MANAGER install"
        echo "  4. Start dev server: $PKG_MANAGER dev"
    else
        echo "✗ Missing required prerequisites:"
        for error in "${ERRORS[@]}"; do
            echo "  - $error"
        done
        echo ""
        echo "Installation Tips:"
        if [[ "$NODE_AVAILABLE" == false ]]; then
            echo "  - Install Node.js v20 LTS: https://nodejs.org/"
            echo "  - Or use version manager: nvm install 20"
        elif [[ "$NODE_MAJOR" -lt 18 ]]; then
            echo "  - Upgrade Node.js: nvm install 20 && nvm use 20"
        fi
        [[ -z "$PNPM_VERSION" ]] && echo "  - Install pnpm (recommended): npm install -g pnpm"
        exit 1
    fi
    echo ""
fi
