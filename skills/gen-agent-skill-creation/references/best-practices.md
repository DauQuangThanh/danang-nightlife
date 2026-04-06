# Agent Skill Creation - Best Practices

## Overview

This document provides advanced guidance for creating high-quality agent skills based on real-world experience and the Agent Skills specification.

## Progressive Disclosure Strategy

### Three-Tier Loading Model

**Tier 1: Metadata (Always Loaded)**

- Size: ~100 tokens per skill
- Content: `name` + `description` fields only
- Purpose: Skill discovery and selection
- Loaded: Agent startup for ALL skills

**Tier 2: Instructions (Load on Activation)**

- Size: <5000 tokens (aim for <500 lines)
- Content: Full SKILL.md body
- Purpose: Detailed execution instructions
- Loaded: When skill activated based on task match

**Tier 3: Resources (Load on Demand)**

- Size: Variable
- Content: scripts/, references/, assets/
- Purpose: Specialized tools and reference data
- Loaded: Only when explicitly required by instructions

### Why This Matters

**Context Window Management:**

```
Without progressive disclosure:
  200 skills × 5000 tokens = 1,000,000 tokens (OVERFLOW)

With progressive disclosure:
  200 skills × 100 tokens = 20,000 tokens (discovery)
  + 1 active skill × 5000 tokens = 25,000 tokens (OPTIMAL)
```

**Key Principle**: Load only what's needed, when it's needed.

## Description Writing Mastery

### The 3-Part Formula

```
[ACTIONS] + [USE CASES] + [KEYWORDS]
```

### Part 1: Actions (What It Does)

✅ **Use active, specific verbs:**

- "Extracts", "Analyzes", "Generates", "Converts", "Validates"
- "Reviews", "Optimizes", "Transforms", "Merges", "Filters"

❌ **Avoid vague terms:**

- "Helps with", "Tool for", "Manages", "Handles"

**Examples:**

- ✅ "Extracts text and tables from PDF files, fills forms, merges documents"
- ❌ "Helps with PDF documents"

### Part 2: Use Cases (When to Use)

✅ **Specific scenarios:**

- "Use when reviewing pull requests"
- "Use for data format conversions"
- "Use during security audits"

❌ **Generic situations:**

- "Use when working with files"
- "Use for development tasks"

### Part 3: Keywords (Matching Terms)

✅ **Terms users might say:**

- Technical: "API", "GraphQL", "REST", "OAuth"
- Non-technical: "slow website", "broken links", "missing data"
- Problem-focused: "errors", "crashes", "performance"

**Example:**

```yaml
description: "Analyzes GraphQL schemas for performance issues, validates resolver implementations, and suggests optimizations. Use when reviewing GraphQL APIs, troubleshooting slow queries, or when user mentions GraphQL, schema design, or resolver problems."
```

### Optimal Length

- **Target**: 150-300 characters
- **Minimum**: 50 characters (too short = poor discovery)
- **Maximum**: 1024 characters (too long = context bloat)

### Testing Descriptions

Ask these questions:

1. Can someone else determine when to use this skill?
2. Would a search for [keyword] find this skill?
3. Are the actions specific enough to differentiate from similar skills?
4. Does it include both technical and user-facing terms?

## Naming Conventions

### Name Format Rules

**Required:**

- Only lowercase letters (a-z)
- Numbers (0-9)
- Hyphens (-) as separators

**Forbidden:**

- Uppercase letters (A-Z)
- Underscores (_)
- Spaces
- Leading or trailing hyphens
- Consecutive hyphens (--)
- Special characters (@, #, $, etc.)

### Naming Strategies

**Strategy 1: Action-Target**

- `pdf-extraction`
- `code-review`
- `api-documentation`

**Strategy 2: Domain-Function**

- `graphql-schema-validator`
- `docker-deployment`
- `aws-cost-optimizer`

**Strategy 3: Tool-Operation**

- `git-workflow-automation`
- `database-migration`
- `elasticsearch-indexing`

### Name Length Best Practices

- **Ideal**: 15-30 characters
- **Minimum**: 3 characters
- **Maximum**: 64 characters

### Validation Command

```bash
# Validate name format
echo "your-skill-name" | grep -E '^[a-z0-9]+(-[a-z0-9]+)*$'

# Returns 0 (success) if valid, 1 (failure) if invalid
```

## SKILL.md Structure Optimization

### Section Priority (What to Keep in Main File)

**Priority 1 (Must have in SKILL.md):**

1. Frontmatter (name, description, metadata)
2. Overview (2-3 sentences)
3. When to Use (3-5 bullet points)
4. Prerequisites (tools, versions)
5. Core Instructions (step-by-step)
6. Basic Examples (2-3 minimum)
7. Common Edge Cases (top 3)
8. Common Errors (top 5)

**Priority 2 (Can move to references/ if >400 lines):**

1. Advanced instructions
2. Extensive examples
3. Detailed edge cases
4. In-depth troubleshooting
5. Background information
6. API documentation

**Priority 3 (Should be in references/):**

1. Theory and concepts
2. Historical context
3. Alternative approaches
4. Research papers
5. External resources
6. Changelog

### Line Budget Allocation

For a 450-line SKILL.md:

```
Frontmatter & Title:        10 lines  (2%)
Overview:                   10 lines  (2%)
When to Use:                15 lines  (3%)
Prerequisites:              20 lines  (4%)
Instructions:              250 lines  (56%)
Examples:                   75 lines  (17%)
Edge Cases:                 30 lines  (7%)
Error Handling:             30 lines  (7%)
Resources/Footer:           10 lines  (2%)
-------------------------------------------
Total:                     450 lines  (100%)
```

### Keeping Under 500 Lines

**Technique 1: Consolidate Examples**

```markdown
❌ Bad (100 lines of examples):
## Example 1: Basic Usage
[30 lines]

## Example 2: Advanced Usage
[35 lines]

## Example 3: Edge Case
[35 lines]

✅ Good (40 lines total):
## Examples

**Basic:** Input → Output
**Advanced:** Input → Output
**Edge Case:** Input → Output

See [references/examples.md](references/examples.md) for complete examples.
```

**Technique 2: Summarize Error Handling**

```markdown
❌ Bad (verbose):
### Error: Command Not Found
**Symptoms:** "jq: command not found" when running script
**Cause:** Missing dependency
**Solution:**
1. Check which tools are required
2. Install missing tools (brew install jq / apt install jq)
3. Verify tool versions match requirements
4. Check PATH is configured correctly

✅ Good (concise):
**Command Not Found:** Install required tools: `brew install jq` (macOS) or `apt install jq` (Linux)

See [references/troubleshooting.md](references/troubleshooting.md) for details.
```

**Technique 3: Reference Linking**

```markdown
✅ In SKILL.md (keep it brief):
For advanced patterns, see [references/advanced-patterns.md](references/advanced-patterns.md)

✅ In references/advanced-patterns.md (full details):
[Comprehensive content without line limit concerns]
```

## Cross-Platform Script Best Practices

### Dual-Script Strategy: Bash + PowerShell

Every skill that includes scripts must provide both formats for true cross-platform coverage:

| Format | File | Runs On | Strengths |
|--------|------|---------|-----------|
| Bash | `.sh` | macOS, Linux, WSL, Git Bash | Native on Unix, CI/CD pipelines, Docker |
| PowerShell | `.ps1` | Windows (5.1+), cross-platform (7+) | Native on Windows, rich object pipeline |

### Essential Bash Patterns

**Pattern 1: Safe Script Header**

```bash
#!/usr/bin/env bash
set -euo pipefail

# -e: exit on error
# -u: error on unset variables
# -o pipefail: catch errors in piped commands
```

**Pattern 2: Cross-Platform Paths**

```bash
# ✅ Good: Use variables and forward slashes
INPUT_DIR="data/files"
OUTPUT_DIR="$HOME/output"

# ❌ Bad: Hardcoded absolute paths
INPUT_DIR="/Users/me/data"
```

**Pattern 3: Argument Parsing**

```bash
INPUT=""
OUTPUT=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)  OUTPUT="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        -*)           echo "Unknown option: $1" >&2; exit 2 ;;
        *)            INPUT="$1"; shift ;;
    esac
done
```

**Pattern 4: Error Handling**

```bash
if [[ ! -f "$INPUT" ]]; then
    echo "Error: File not found: $INPUT" >&2
    echo "Expected path: $(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")" >&2
    echo "Hint: Check file path and permissions" >&2
    exit 1
fi
```

### Essential PowerShell Patterns

**Pattern 1: Script Header**

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Input,

    [Parameter()]
    [string]$Output,

    [Parameter()]
    [switch]$Quiet
)
```

**Pattern 2: Cross-Platform Paths**

```powershell
# ✅ Good: Use Join-Path
$outputPath = Join-Path $env:HOME "output" "result.txt"

# ❌ Bad: Hardcoded separators
$outputPath = "C:\Users\me\output\result.txt"
```

**Pattern 3: Error Handling**

```powershell
try {
    if (-not (Test-Path -Path $Input -PathType Leaf)) {
        Write-Error "File not found: $Input"
        exit 1
    }
    # Your logic here
}
catch {
    Write-Error "Unexpected error: $_"
    exit 1
}
```

### Script Template Checklist

**Bash:**

- [ ] Shebang line: `#!/usr/bin/env bash`
- [ ] `set -euo pipefail` at the top
- [ ] Comments with usage, platforms, requirements
- [ ] Quoted variables: `"$VAR"` not `$VAR`
- [ ] `[[ ]]` for conditionals (not `[ ]`)
- [ ] Proper exit codes (0 success, 1 error, 2 usage, 130 interrupted)

**PowerShell:**

- [ ] `[CmdletBinding()]` and `param()` block
- [ ] Comment-based help (`.SYNOPSIS`, `.PARAMETER`, `.EXAMPLE`)
- [ ] `Test-Path` for file/directory checks
- [ ] `Join-Path` for path construction
- [ ] Proper exit codes matching Bash counterpart

### Testing Cross-Platform Scripts

**Test Matrix:**

```bash
# macOS (Terminal)
bash scripts/process.sh test-data.txt

# Linux (Bash)
bash scripts/process.sh test-data.txt

# Windows (PowerShell)
.\scripts\process.ps1 -Input test-data.txt

# WSL (Windows Subsystem for Linux)
bash scripts/process.sh test-data.txt

# Docker (isolated Linux)
docker run -v $(pwd):/work -w /work bash:5 \
    bash scripts/process.sh test-data.txt
```

## Validation and Quality Assurance

### Pre-Deployment Checklist

**Structure Validation:**

```bash
# Check name format
[[ "$(basename $(pwd))" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && echo "✅ Name valid" || echo "❌ Name invalid"

# Count lines
lines=$(wc -l < SKILL.md)
[[ $lines -lt 500 ]] && echo "✅ Under 500 lines ($lines)" || echo "⚠️ Too long ($lines)"

# Check for external references
! grep -q "https://" SKILL.md && echo "✅ No external URLs" || echo "⚠️ External URLs found"
! grep -q "/rules/" SKILL.md && echo "✅ No /rules/ refs" || echo "⚠️ /rules/ reference found"
```

**Content Validation:**

```bash
# Check required sections
for section in "## When to Use" "## Prerequisites" "## Instructions" "## Examples" "## Edge Cases" "## Error Handling"; do
    grep -q "$section" SKILL.md && echo "✅ $section" || echo "❌ Missing $section"
done

# Verify frontmatter
head -1 SKILL.md | grep -q "^---$" && echo "✅ Frontmatter start" || echo "❌ No frontmatter"
```

**Script Validation:**

```bash
# Check Bash scripts
for script in scripts/*.sh; do
    [[ -f "$script" ]] || continue
    echo "Checking $script..."
    
    # Check shebang
    head -1 "$script" | grep -q "#!/usr/bin/env bash" && echo "  ✅ Shebang" || echo "  ⚠️ Missing shebang"
    
    # Check syntax
    bash -n "$script" 2>/dev/null && echo "  ✅ Syntax valid" || echo "  ❌ Syntax error"
    
    # Check for set -euo pipefail
    grep -q "set -euo pipefail" "$script" && echo "  ✅ Uses strict mode" || echo "  ⚠️ Missing set -euo pipefail"

    # Check executable permission
    [[ -x "$script" ]] && echo "  ✅ Executable" || echo "  ⚠️ Not executable"
done

# Check PowerShell scripts
for script in scripts/*.ps1; do
    [[ -f "$script" ]] || continue
    echo "Checking $script..."
    
    # Check for CmdletBinding
    grep -q "CmdletBinding" "$script" && echo "  ✅ Uses CmdletBinding" || echo "  ⚠️ Missing CmdletBinding"
    
    # Check for param block
    grep -q "param(" "$script" && echo "  ✅ Has param block" || echo "  ⚠️ Missing param block"
done
```

### Automated Validation Script

See [scripts/validate-skill.sh](../scripts/validate-skill.sh) (Bash) or [scripts/validate-skill.ps1](../scripts/validate-skill.ps1) (PowerShell) for comprehensive automated validation.

## Common Anti-Patterns to Avoid

### Anti-Pattern 1: Implicit Dependencies

❌ **Bad:**

```markdown
## Instructions
1. Run the script
2. Process the output
```

✅ **Good:**

```markdown
## Prerequisites
- Bash 4.0+ (macOS/Linux/WSL)
- PowerShell 5.1+ (Windows)
- jq: `brew install jq` / `choco install jq`

## Instructions
1. Run the script: `bash scripts/process.sh input.csv`
   Or on Windows: `.\scripts\process.ps1 -Input input.csv`
```

### Anti-Pattern 2: Platform-Specific Assumptions

❌ **Bad:**

```bash
output_path="C:\Users\output\file.txt"
```

✅ **Good:**

```bash
output_path="$HOME/output/file.txt"
```

### Anti-Pattern 3: Vague Instructions

❌ **Bad:**

```markdown
1. Prepare the data
2. Run the analysis
3. Review the results
```

✅ **Good:**

```markdown
1. Convert CSV to JSON: `bash scripts/convert.sh input.csv output.json`
2. Validate schema: `bash scripts/validate.sh output.json`
3. Review validation report in `validation-report.txt`
```

### Anti-Pattern 4: Missing Error Context

❌ **Bad:**

```bash
if [[ ! -f "$FILE" ]]; then
    echo "Error" >&2
    exit 1
fi
```

✅ **Good:**

```bash
if [[ ! -f "$FILE" ]]; then
    echo "Error: Input file not found: $FILE" >&2
    echo "Expected path: $(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")" >&2
    echo "Hint: Check file path and permissions" >&2
    exit 1
fi
```

### Anti-Pattern 5: Monolithic SKILL.md

❌ **Bad:** 1200-line SKILL.md with everything

✅ **Good:**

```
skill-name/
├── SKILL.md (450 lines, core instructions)
├── references/
│   ├── advanced-usage.md
│   ├── api-reference.md
│   └── examples.md
└── scripts/
    ├── process.sh
    └── process.ps1
```

## Integration with Agent Platforms

### Claude Code

```bash
# Add skills from marketplace
/plugin marketplace add anthropics/skills

# Install specific skill
/plugin install pdf-skills@anthropic-agent-skills

# Use skill by mentioning it
"Use the PDF skill to extract tables from report.pdf"
```

### General Best Practices

1. **Test with target platform**: Verify skill works in intended environment
2. **Provide clear activation**: Make description keyword-rich
3. **Document platform differences**: Note any platform-specific behavior
4. **Version compatibility**: Specify minimum agent/platform versions if needed

## Maintenance and Updates

### When to Update a Skill

- **Critical**: Security vulnerabilities, breaking bugs
- **Important**: New features, improved documentation
- **Nice-to-have**: Minor improvements, additional examples

### Versioning Strategy

```yaml
metadata:
  version: "2.1.0"  # Major.Minor.Patch
  last_updated: "2026-02-01"
```

- **Major**: Breaking changes, complete rewrites
- **Minor**: New features, significant improvements
- **Patch**: Bug fixes, documentation updates

### Changelog Practice

Keep a CHANGELOG.md or add to frontmatter:

```yaml
metadata:
  version: "2.1.0"
  changelog: |
    2.1.0: Added validation script, improved examples
    2.0.0: Restructured for Agent Skills v1 spec
    1.0.0: Initial release
```

## Tips for Mastery

1. **Start minimal**: Get core functionality working first
2. **Iterate based on usage**: Add features as needed
3. **Collect feedback**: Learn from users and improve
4. **Study existing skills**: Learn from high-quality examples
5. **Test thoroughly**: Verify on all target platforms
6. **Document well**: Future you will thank present you
7. **Stay updated**: Follow Agent Skills specification changes
8. **Share knowledge**: Contribute back to the community

---

**Version**: 1.0  
**Last Updated**: 2026-02-01
