#!/usr/bin/env bash
# License Scanner — scans project dependencies and classifies licenses.
# Usage: bash scripts/license-scan.sh [project_root] [--ecosystem npm|python|go|java|dotnet] [--strict] [--json]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+, ecosystem-specific tools (npm, pip-licenses, go-licenses, mvn, dotnet)

set -euo pipefail

# ---------------------------------------------------------------------------
# License classification tiers (SPDX identifiers)
# ---------------------------------------------------------------------------

APPROVED="MIT Apache-2.0 BSD-2-Clause BSD-3-Clause ISC CC0-1.0 Unlicense 0BSD"
CONDITIONAL="MPL-2.0 LGPL-2.1 LGPL-2.1-only LGPL-2.1-or-later LGPL-3.0 LGPL-3.0-only LGPL-3.0-or-later EPL-2.0 CDDL-1.0"
RESTRICTED="GPL-2.0 GPL-2.0-only GPL-2.0-or-later GPL-3.0 GPL-3.0-only GPL-3.0-or-later AGPL-3.0 AGPL-3.0-only AGPL-3.0-or-later SSPL-1.0 BSL-1.1"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

PROJECT_ROOT="."
ECOSYSTEM=""
STRICT=false
JSON_OUTPUT=false

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ecosystem) ECOSYSTEM="$2"; shift 2 ;;
        --strict) STRICT=true; shift ;;
        --json) JSON_OUTPUT=true; shift ;;
        --help|-h)
            echo "Usage: $(basename "$0") [project_root] [--ecosystem npm|python|go|java|dotnet] [--strict] [--json]"
            echo ""
            echo "Scans project dependencies and classifies licenses into tiers:"
            echo "  APPROVED:    MIT, Apache-2.0, BSD-2/3-Clause, ISC, CC0-1.0, Unlicense"
            echo "  CONDITIONAL: MPL-2.0, LGPL-2.1/3.0, EPL-2.0, CDDL-1.0"
            echo "  RESTRICTED:  GPL-2.0/3.0, AGPL-3.0, SSPL, BSL (BLOCKED)"
            echo "  UNKNOWN:     No license or unrecognized (BLOCKED)"
            echo ""
            echo "Options:"
            echo "  --ecosystem   Force ecosystem (npm, python, go, java, dotnet)"
            echo "  --strict      Also block CONDITIONAL licenses"
            echo "  --json        Output as JSON"
            exit 0
            ;;
        -*) echo "Unknown option: $1" >&2; exit 2 ;;
        *) PROJECT_ROOT="$1"; shift ;;
    esac
done

if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "Error: Project root does not exist: $PROJECT_ROOT" >&2
    exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# ---------------------------------------------------------------------------
# Classify a license string
# ---------------------------------------------------------------------------

classify_license() {
    local lic="$1"
    # Handle OR expressions — pick most permissive
    if [[ "$lic" == *" OR "* ]] || [[ "$lic" == *" or "* ]]; then
        local parts
        IFS='|' read -ra parts <<< "$(echo "$lic" | sed 's/ [Oo][Rr] /|/g')"
        for part in "${parts[@]}"; do
            part="$(echo "$part" | xargs)" # trim
            local tier
            tier=$(classify_license "$part")
            if [[ "$tier" == "APPROVED" ]]; then
                echo "APPROVED"; return
            fi
        done
    fi
    for a in $APPROVED; do
        if [[ "${lic,,}" == "${a,,}" ]]; then echo "APPROVED"; return; fi
    done
    for c in $CONDITIONAL; do
        if [[ "${lic,,}" == "${c,,}" ]]; then echo "CONDITIONAL"; return; fi
    done
    for r in $RESTRICTED; do
        if [[ "${lic,,}" == "${r,,}" ]]; then echo "RESTRICTED"; return; fi
    done
    echo "UNKNOWN"
}

# ---------------------------------------------------------------------------
# Detect ecosystem
# ---------------------------------------------------------------------------

detect_ecosystem() {
    local root="$1"
    if [[ -f "$root/package.json" ]]; then echo "npm"; return; fi
    if [[ -f "$root/requirements.txt" ]] || [[ -f "$root/pyproject.toml" ]]; then echo "python"; return; fi
    if [[ -f "$root/go.mod" ]]; then echo "go"; return; fi
    if [[ -f "$root/pom.xml" ]]; then echo "java"; return; fi
    if compgen -G "$root/*.csproj" > /dev/null 2>&1; then echo "dotnet"; return; fi
    echo ""
}

# ---------------------------------------------------------------------------
# Scan functions per ecosystem
# ---------------------------------------------------------------------------

scan_npm() {
    local root="$1"
    if command -v npx &> /dev/null && [[ -f "$root/package.json" ]]; then
        # Use license-checker if available
        if npx --yes license-checker --json --start "$root" 2>/dev/null; then
            return
        fi
    fi
    # Fallback: parse package-lock.json
    if [[ -f "$root/package-lock.json" ]] && command -v node &> /dev/null; then
        node -e "
            const lock = require('$root/package-lock.json');
            const pkgs = lock.packages || {};
            Object.entries(pkgs).forEach(([k, v]) => {
                if (k && k !== '' && v.license) {
                    const name = k.replace('node_modules/', '');
                    console.log(name + '\t' + (v.version || '*') + '\t' + v.license);
                }
            });
        " 2>/dev/null || true
    fi
}

scan_python() {
    local root="$1"
    if command -v pip-licenses &> /dev/null; then
        pip-licenses --format=json 2>/dev/null || true
        return
    fi
    # Fallback: parse requirements.txt and look up dist-info
    if [[ -f "$root/requirements.txt" ]]; then
        while IFS= read -r line; do
            line="$(echo "$line" | xargs)"
            [[ -z "$line" || "$line" == \#* || "$line" == -* ]] && continue
            local name version
            name="$(echo "$line" | sed 's/[><=!~].*//' | xargs)"
            version="$(echo "$line" | grep -oP '[\d][\d.]*' | head -1 || echo '*')"
            echo "${name}\t${version}\tUNKNOWN"
        done < "$root/requirements.txt"
    fi
}

scan_go() {
    local root="$1"
    if command -v go-licenses &> /dev/null; then
        (cd "$root" && go-licenses csv ./... 2>/dev/null) || true
        return
    fi
    # Fallback: parse go.mod
    if [[ -f "$root/go.mod" ]]; then
        local in_require=false
        while IFS= read -r line; do
            line="$(echo "$line" | xargs)"
            if [[ "$line" == "require ("* ]]; then in_require=true; continue; fi
            if [[ "$in_require" == true && "$line" == ")" ]]; then in_require=false; continue; fi
            if [[ "$in_require" == true ]]; then
                local module version
                module="$(echo "$line" | awk '{print $1}')"
                version="$(echo "$line" | awk '{print $2}')"
                echo "${module}\t${version}\tUNKNOWN"
            fi
        done < "$root/go.mod"
    fi
}

scan_java() {
    local root="$1"
    if [[ -f "$root/pom.xml" ]] && command -v mvn &> /dev/null; then
        (cd "$root" && mvn license:third-party-report -q 2>/dev/null) || true
        return
    fi
    # Fallback: parse pom.xml for dependency names
    if [[ -f "$root/pom.xml" ]]; then
        grep -oP '<dependency>.*?</dependency>' "$root/pom.xml" 2>/dev/null | while read -r dep_block; do
            local gid aid ver
            gid="$(echo "$dep_block" | grep -oP '<groupId>\K[^<]+')" || true
            aid="$(echo "$dep_block" | grep -oP '<artifactId>\K[^<]+')" || true
            ver="$(echo "$dep_block" | grep -oP '<version>\K[^<]+')" || ver="*"
            echo "${gid}:${aid}\t${ver}\tUNKNOWN"
        done
    fi
}

scan_dotnet() {
    local root="$1"
    if command -v dotnet &> /dev/null; then
        (cd "$root" && dotnet list package --format json 2>/dev/null) || true
        return
    fi
    # Fallback: parse .csproj files
    for csproj in "$root"/*.csproj; do
        [[ -f "$csproj" ]] || continue
        grep -oP 'PackageReference Include="([^"]+)" Version="([^"]+)"' "$csproj" 2>/dev/null | while read -r match; do
            local name ver
            name="$(echo "$match" | grep -oP 'Include="\K[^"]+')"
            ver="$(echo "$match" | grep -oP 'Version="\K[^"]+')"
            echo "${name}\t${ver}\tUNKNOWN"
        done
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

ECO="${ECOSYSTEM:-$(detect_ecosystem "$PROJECT_ROOT")}"

if [[ -z "$ECO" ]]; then
    echo "Error: No supported dependency manifest found in $PROJECT_ROOT" >&2
    echo "Supported: package.json, requirements.txt, pyproject.toml, go.mod, pom.xml, *.csproj" >&2
    exit 1
fi

echo "Ecosystem: $ECO"
echo "Project root: $PROJECT_ROOT"
echo ""

# Run scan
TOTAL=0
APPROVED_COUNT=0
CONDITIONAL_COUNT=0
RESTRICTED_COUNT=0
UNKNOWN_COUNT=0
BLOCKED_DEPS=""

case "$ECO" in
    npm) SCAN_OUTPUT="$(scan_npm "$PROJECT_ROOT")" ;;
    python) SCAN_OUTPUT="$(scan_python "$PROJECT_ROOT")" ;;
    go) SCAN_OUTPUT="$(scan_go "$PROJECT_ROOT")" ;;
    java) SCAN_OUTPUT="$(scan_java "$PROJECT_ROOT")" ;;
    dotnet) SCAN_OUTPUT="$(scan_dotnet "$PROJECT_ROOT")" ;;
    *)
        echo "Error: Unsupported ecosystem: $ECO" >&2
        exit 1
        ;;
esac

echo "Dependencies found:"
echo ""

# Process results (simple tab-delimited: name\tversion\tlicense)
while IFS=$'\t' read -r name version license; do
    [[ -z "$name" ]] && continue
    TOTAL=$((TOTAL + 1))
    tier="$(classify_license "$license")"
    echo "  [$tier] $name@$version  ($license)"

    case "$tier" in
        APPROVED) APPROVED_COUNT=$((APPROVED_COUNT + 1)) ;;
        CONDITIONAL) CONDITIONAL_COUNT=$((CONDITIONAL_COUNT + 1)) ;;
        RESTRICTED) RESTRICTED_COUNT=$((RESTRICTED_COUNT + 1)); BLOCKED_DEPS="${BLOCKED_DEPS}  - $name@$version [$license] (RESTRICTED)\n" ;;
        UNKNOWN) UNKNOWN_COUNT=$((UNKNOWN_COUNT + 1)); BLOCKED_DEPS="${BLOCKED_DEPS}  - $name@$version [$license] (UNKNOWN)\n" ;;
    esac

    if [[ "$STRICT" == true && "$tier" == "CONDITIONAL" ]]; then
        BLOCKED_DEPS="${BLOCKED_DEPS}  - $name@$version [$license] (CONDITIONAL - strict mode)\n"
    fi
done <<< "$SCAN_OUTPUT"

echo ""
echo "Summary:"
echo "  Total: $TOTAL"
echo "  Approved: $APPROVED_COUNT"
echo "  Conditional: $CONDITIONAL_COUNT"
echo "  Restricted: $RESTRICTED_COUNT"
echo "  Unknown: $UNKNOWN_COUNT"
echo ""

if [[ -n "$BLOCKED_DEPS" ]]; then
    echo "STATUS: BLOCKED"
    echo "Blocked dependencies:"
    echo -e "$BLOCKED_DEPS"
    exit 1
else
    echo "STATUS: PASS"
    exit 0
fi
