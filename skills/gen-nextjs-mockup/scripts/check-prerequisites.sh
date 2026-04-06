#!/usr/bin/env bash
# Next.js Mockup Prerequisites Checker
# Verifies Node.js and package manager availability.
#
# Usage: bash scripts/check-prerequisites.sh [--json]
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
ALL_OK=true

# Check Node.js
if command -v node &>/dev/null; then
    NODE_AVAILABLE=true
    NODE_VERSION="$(node --version | sed 's/^v//')"
    NODE_MAJOR="${NODE_VERSION%%.*}"
else
    ALL_OK=false
fi

# Check pnpm first (recommended), then npm
if command -v pnpm &>/dev/null; then
    PKG_MANAGER="pnpm"
    PKG_VERSION="$(pnpm --version)"
elif command -v npm &>/dev/null; then
    PKG_MANAGER="npm"
    PKG_VERSION="$(npm --version)"
else
    ALL_OK=false
fi

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

if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{"node":{"available":$NODE_AVAILABLE,"version":"$NODE_VERSION","major_version":$NODE_MAJOR},"package_manager":{"name":"$PKG_MANAGER","version":"$PKG_VERSION"},"workspace_root":"$WORKSPACE_ROOT","all_ok":$ALL_OK}
EOF
else
    echo "Next.js Mockup - Prerequisites Check"
    echo "============================================="

    if [[ "$NODE_AVAILABLE" == true ]]; then
        echo "[OK] Node.js v$NODE_VERSION detected"
        if [[ "$NODE_MAJOR" -lt 18 ]]; then
            echo "[WARN] Node.js 18+ required, 20+ recommended"
            ALL_OK=false
        fi
    else
        echo "[FAIL] Node.js not found"
    fi

    if [[ -n "$PKG_MANAGER" ]]; then
        if [[ "$PKG_MANAGER" == "pnpm" ]]; then
            echo "[OK] pnpm v$PKG_VERSION detected (recommended)"
        else
            echo "[OK] npm v$PKG_VERSION detected"
        fi
    else
        echo "[FAIL] No package manager found (npm or pnpm required)"
    fi

    if [[ "$ALL_OK" == true ]]; then
        echo "[OK] All prerequisites met. Ready to create Next.js mockups!"
    else
        echo "[FAIL] Some prerequisites are missing. Please install required tools."
        exit 1
    fi
fi
