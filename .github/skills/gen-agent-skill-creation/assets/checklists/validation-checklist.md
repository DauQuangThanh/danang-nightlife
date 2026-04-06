# Skill Validation Checklist

## Quick Validation Commands

### Name Format Validation

```bash
# Check if name matches pattern: lowercase, hyphens, numbers only
echo "skill-name" | grep -E '^[a-z0-9]+(-[a-z0-9]+)*$' && echo "✅ Valid" || echo "❌ Invalid"
```

### Line Count Check

```bash
# Count lines in SKILL.md (should be < 500)
wc -l SKILL.md
```

### External References Check

```bash
# Check for /rules/ references (should have none)
grep -n "/rules/" SKILL.md

# Check for external URLs
grep -n "https://" SKILL.md
```

### YAML Frontmatter Validation

```bash
# Check frontmatter exists
head -1 SKILL.md | grep -q "^---$" && echo "✅ Frontmatter start" || echo "❌ No frontmatter"

# Check required fields
grep -m1 "^name:" SKILL.md && echo "✅ Name field found" || echo "❌ Missing name field"
grep -m1 "^description:" SKILL.md && echo "✅ Description field found" || echo "❌ Missing description field"

# Check name matches directory
skill_name=$(basename "$(pwd)")
yaml_name=$(grep -m1 "^name:" SKILL.md | sed 's/^name:[[:space:]]*//' | tr -d '"'"'")
[[ "$yaml_name" == "$skill_name" ]] && echo "✅ Name matches directory" || echo "❌ Name mismatch: '$yaml_name' vs '$skill_name'"
```

## Complete Validation Checklist

### Structure Validation

- [ ] SKILL.md file exists
- [ ] SKILL.md starts with `---` (YAML frontmatter)
- [ ] SKILL.md frontmatter ends with `---`
- [ ] SKILL.md is under 500 lines
- [ ] Skill name matches directory name exactly
- [ ] Name format: lowercase, hyphens, numbers only (1-64 chars)
- [ ] No leading/trailing hyphens in name
- [ ] No consecutive hyphens (`--`) in name
- [ ] No external references to `/rules/` directory
- [ ] Skill is self-contained (all resources within directory)

### Required Frontmatter Fields

- [ ] `name` field present
- [ ] `name` matches pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- [ ] `name` length is 1-64 characters
- [ ] `description` field present
- [ ] `description` length is 1-1024 characters
- [ ] `description` is specific (not vague)

### Recommended Frontmatter Fields

- [ ] `license` field present (MIT recommended)
- [ ] `metadata.author` present
- [ ] `metadata.version` present (e.g., "1.0")
- [ ] `metadata.last_updated` present (YYYY-MM-DD format)

### Description Quality

- [ ] Includes 2-4 specific action verbs
- [ ] Includes "Use when..." with 2-3 scenarios
- [ ] Includes "when user mentions..." with 3-5 keywords
- [ ] Length is 150-300 characters (optimal)
- [ ] Avoids vague terms ("helps with", "tool for")
- [ ] Specific enough to differentiate from similar skills

### Content Sections (Required in SKILL.md)

- [ ] `# Skill Name` (H1 title)
- [ ] `## Overview` section (2-3 sentences)
- [ ] `## When to Use` section (3-5 bullet points)
- [ ] `## Prerequisites` section (or "None")
- [ ] `## Instructions` section (step-by-step)
- [ ] `## Examples` section (at least 2 examples)
- [ ] `## Edge Cases` section (2-3 cases)
- [ ] `## Error Handling` section (common errors)

### Optional Content Sections

- [ ] `## Scripts` (if scripts/ directory exists)
- [ ] `## References` (if references/ directory exists)
- [ ] `## Validation` section
- [ ] Footer with version, author, license

### Examples Quality

- [ ] At least 2 complete examples
- [ ] Each example shows input
- [ ] Each example shows output
- [ ] Examples cover common use cases
- [ ] Examples are concrete (not abstract)

### Instructions Quality

- [ ] Steps are numbered
- [ ] Each step has clear action verb
- [ ] Code examples included where relevant
- [ ] Commands are copy-paste ready
- [ ] Platform differences documented (if any)

### Scripts Directory (if present)

- [ ] Both formats provided: .sh (Bash) and .ps1 (PowerShell)
- [ ] Bash scripts have shebang: `#!/usr/bin/env bash`
- [ ] Bash scripts use `set -euo pipefail`
- [ ] PowerShell scripts use `[CmdletBinding()]` and `param()`
- [ ] Scripts have usage documentation in header comments/help blocks
- [ ] Scripts have error handling with clear messages
- [ ] Bash scripts tested on macOS and Linux
- [ ] PowerShell scripts tested on Windows

### References Directory (if present)

- [ ] Referenced from SKILL.md
- [ ] One topic per file
- [ ] Clear structure with headings
- [ ] Files use `.md` extension

### Templates Directory (if present)

- [ ] Contains reusable templates
- [ ] Templates are well-documented
- [ ] Templates follow same standards as main skill

### Assets Directory (if present)

- [ ] Contains static resources
- [ ] Referenced from SKILL.md or references/
- [ ] Examples are complete and working
- [ ] Checklists are comprehensive

### Cross-Platform Compatibility

- [ ] Both Bash and PowerShell scripts provided with equivalent functionality
- [ ] No hardcoded platform-specific paths
- [ ] Consistent argument names across both formats
- [ ] File references use forward slashes
- [ ] Line endings configured in `.gitattributes` (if needed)
- [ ] Bash scripts tested on macOS and Linux
- [ ] PowerShell scripts tested on Windows

### Final Checks

- [ ] SKILL.md renders correctly in Markdown viewer
- [ ] All internal links resolve correctly
- [ ] No broken references
- [ ] No typos in critical sections
- [ ] Consistent terminology throughout
- [ ] Clear and actionable error messages
- [ ] Version number updated (if updating existing skill)
- [ ] Last updated date current

## Quick Test Commands

```bash
# Navigate to skill directory
cd /path/to/skill-name

# Run all checks
echo "=== Structure Check ==="
[[ -f "SKILL.md" ]] && echo "✅ SKILL.md exists" || echo "❌ SKILL.md missing"
[[ $(wc -l < SKILL.md) -lt 500 ]] && echo "✅ Under 500 lines" || echo "⚠️ Over 500 lines"

echo -e "\n=== Name Check ==="
skill_name=$(basename $(pwd))
echo "Directory name: $skill_name"
[[ "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && echo "✅ Valid format" || echo "❌ Invalid format"

echo -e "\n=== External References Check ==="
! grep -q "/rules/" SKILL.md && echo "✅ No /rules/ refs" || echo "❌ Has /rules/ refs"

echo -e "\n=== Required Sections Check ==="
for section in "## When to Use" "## Prerequisites" "## Instructions" "## Examples" "## Edge Cases" "## Error Handling"; do
    grep -q "$section" SKILL.md && echo "✅ $section" || echo "❌ Missing: $section"
done
```

## Automated Validation

Use the provided validation scripts for comprehensive automated checks:

```bash
# Bash (macOS/Linux/WSL) — validate a single skill
bash scripts/validate-skill.sh ./skill-name

# Bash — validate all skills in a directory
bash scripts/validate-skill.sh ./skills/

# PowerShell (Windows) — validate a single skill
.\scripts\validate-skill.ps1 -Path ./skill-name

# PowerShell — validate all skills in a directory
.\scripts\validate-skill.ps1 -Path ./skills/
```

---

**Note**: The validation scripts (`validate-skill.sh` and `validate-skill.ps1`) are located in the `scripts/` directory and can be run from any location by providing the full path.
