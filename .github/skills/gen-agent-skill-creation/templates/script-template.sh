#!/usr/bin/env bash
# [Script Name] - [Brief description]
#
# This script [what it does in one sentence].
#
# Usage:
#     bash scripts/script-name.sh <input> [options]
#     bash scripts/script-name.sh --help
#
# Examples:
#     bash scripts/script-name.sh input.txt
#     bash scripts/script-name.sh input.txt --output result.txt
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
#     130 - Interrupted by user (Ctrl+C)
#
# Author: [Your Name]
# Version: 1.0
# License: MIT

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ── Helper functions ────────────────────────────────────────────────
print_success() { printf "${GREEN}✓ %s${NC}\n" "$1"; }
print_error()   { printf "${RED}✗ %s${NC}\n" "$1" >&2; }
print_info()    { printf "${BLUE}ℹ %s${NC}\n" "$1"; }
print_warning() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <input> [options]

Arguments:
    input           Input file path (required)

Options:
    -o, --output    Output file path (default: stdout)
    -f, --format    Output format: text, json, csv (default: text)
    -v, --verbose   Enable verbose output
    -q, --quiet     Suppress non-error output
    -h, --help      Show this help message
EOF
}

# ── Argument parsing ────────────────────────────────────────────────
INPUT=""
OUTPUT=""
FORMAT="text"
VERBOSE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)  OUTPUT="$2"; shift 2 ;;
        -f|--format)  FORMAT="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -q|--quiet)   QUIET=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        -*)           print_error "Unknown option: $1"; usage; exit 2 ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"; shift
            else
                print_error "Unexpected argument: $1"; usage; exit 2
            fi
            ;;
    esac
done

# ── Validation ──────────────────────────────────────────────────────
if [[ -z "$INPUT" ]]; then
    print_error "Input file is required"
    usage
    exit 2
fi

if [[ ! -f "$INPUT" ]]; then
    print_error "Input file not found: $INPUT"
    exit 1
fi

if $VERBOSE && $QUIET; then
    print_error "--verbose and --quiet cannot be used together"
    exit 2
fi

# ── Main logic ──────────────────────────────────────────────────────
if $VERBOSE; then
    print_info "Processing $INPUT..."
fi

# Replace this with your actual processing logic
CONTENT=$(cat "$INPUT")

# Format output
case "$FORMAT" in
    json) RESULT="{\"content\": \"$CONTENT\"}" ;;
    csv)  RESULT="content"$'\n'"$CONTENT" ;;
    *)    RESULT="$CONTENT" ;;
esac

# Write output
if [[ -n "$OUTPUT" ]]; then
    echo "$RESULT" > "$OUTPUT"
    if $VERBOSE; then
        print_info "Output written to: $OUTPUT"
    fi
else
    echo "$RESULT"
fi

if ! $QUIET; then
    print_success "Success" >&2
fi
