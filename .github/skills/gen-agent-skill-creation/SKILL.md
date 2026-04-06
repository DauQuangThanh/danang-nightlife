---
name: gen-agent-skill-creation
description: Generates and updates agent skills following the Agent Skills specification. Creates SKILL.md files with proper frontmatter, organizes supporting files, validates structure, and ensures cross-platform compatibility. Use when creating new agent skills, updating existing skills, converting documentation to skills format, or when user mentions agent skills, skill generation, or Agent Skills specification.
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "3.0"
  last_updated: "2026-02-08"
---

# General Agent Skill Creation

## Overview

This self-contained skill helps AI agents create and update agent skills that conform to the Agent Skills specification. It provides everything needed: instructions, templates, examples, validation rules, and scripts—all within this skill directory.

**Key Concept: Progressive Disclosure**

- **Tier 1** (Always loaded): Metadata (name + description) for discovery  
- **Tier 2** (On activation): This SKILL.md with instructions (<500 lines)
- **Tier 3** (On demand): references/, templates/, scripts/, assets/

## When to Use

- Creating new agent skills from scratch
- Converting existing documentation to agent skills format
- Updating or refactoring existing agent skills
- Validating skill structure and compliance
- Reviewing skills for quality and completeness
- When user requests "create a skill", "generate skill", or mentions Agent Skills specification

## What This Skill Does

1. **Generates SKILL.md files** with proper YAML frontmatter
2. **Organizes supporting files** into scripts/, references/, and assets/ directories
3. **Validates structure** against Agent Skills specification
4. **Ensures cross-platform compatibility** with Bash (.sh) and PowerShell (.ps1) scripts
5. **Writes effective descriptions** for skill discovery
6. **Keeps main file concise** (<500 lines) using progressive disclosure
7. **100% self-contained** - no external dependencies

## Prerequisites

- Understanding of target skill's domain and purpose
- Bash 4.0+ (macOS/Linux/WSL) for shell scripts
- PowerShell 5.1+ (Windows) or PowerShell 7+ (cross-platform) for PowerShell scripts

## Core Instructions

**Deliverable**: A validated skill directory containing SKILL.md (with frontmatter + instructions under 500 lines), and optionally scripts/ (.sh + .ps1 pairs), references/, templates/, and assets/. Done when validation script passes all checks.

### Scope Assessment

Before starting, determine complexity to avoid unnecessary work:

- **Minimal** (SKILL.md only): Skill needs no automation or extensive docs → skip Steps 6-7
- **Standard** (+ scripts/): Skill needs automation → include Step 6
- **Complex** (+ scripts/ + references/): Content exceeds 400 lines → include Steps 6-7

### Step 1: Gather Requirements

**Before doing any work**, collect these from the user or infer from context:

1. **Purpose**: What task or problem does it solve?
2. **Capabilities**: What specific actions can it perform?
3. **Use cases**: When should agents activate this skill?
4. **Keywords**: What terms might users mention?
5. **Dependencies**: Required tools, packages, or environment?

**When to ask the user vs. proceed:**

- **Ask** if: purpose is ambiguous, multiple valid interpretations exist, or scope is unclear
- **Proceed** if: request is specific, context is sufficient from conversation, or reasonable defaults exist
- **Limit**: Maximum 3 clarification questions before proceeding

### Step 2: Choose Skill Name

**Naming rules (CRITICAL):**

✅ **Valid**: lowercase letters (a-z), numbers (0-9), hyphens (-)  
❌ **Invalid**: uppercase, underscores, spaces, leading/trailing hyphens, consecutive hyphens (--)  
📏 **Length**: 1-64 characters  
🔗 **Must match**: Directory name

**Examples:**

- ✅ `pdf-processing`, `code-review`, `api-documentation`
- ❌ `PDF-Processing` (uppercase), `pdf_processing` (underscore), `pdf processing` (space), `-pdf` (leading hyphen)

### Step 3: Write Description

**Use the 3-part formula:**

```
[Active Verbs] + [Use when Scenarios] + [User Mentions/Keywords]
```

**Template:**

```yaml
description: "[Action 1] and [Action 2]. Use when [Scenario 1] or [Scenario 2], or when user mentions [Keyword 1] or [Keyword 2]."
```

**Requirements:**

- Length: 150-300 characters optimal (max 1024)
- Include 2-4 specific actions (active verbs)
- Include 2-3 use cases starting with "Use when..."
- **Critical:** Include keywords clause ("or when user mentions...") for discovery
- Be specific, not vague

**Example:**

```yaml
description: "Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents, extracting form data, or when user mentions PDFs, forms, or document extraction."
```

**Bad Example:**

```yaml
description: "Helps with PDFs."  # Too vague, missing use cases and keywords
```

### Step 4: Generate Skill Structure

**Use the generator script (Recommended):**

```bash
bash scripts/generate-skill.sh skill-name          # macOS/Linux/WSL
.\scripts\generate-skill.ps1 -Name skill-name      # Windows PowerShell
```

This creates the directory, `SKILL.md` with frontmatter, and sample scripts (.sh, .ps1).

**Manual creation (Fallback):**

**Minimal structure (always required):**

```
skill-name/
└── SKILL.md
```

**Full structure (when needed):**

```
skill-name/
├── SKILL.md                     # Core skill definition (<500 lines)
├── scripts/                     # Cross-platform automation
│   ├── process.sh               # Bash (macOS/Linux/WSL)
│   ├── process.ps1              # PowerShell (Windows/cross-platform)
│   ├── validate.sh              # Bash validation
│   └── validate.ps1             # PowerShell validation
├── references/                  # Detailed documentation
│   ├── best-practices.md
│   ├── advanced-patterns.md
│   └── troubleshooting.md
├── templates/                   # Ready-to-use files
│   ├── skill-template.md
│   ├── script-template.sh
│   └── script-template.ps1
└── assets/                      # Static resources
    ├── examples/               # Complete example skills
    └── checklists/            # Validation checklists
```

**When to add optional directories:**

- `scripts/`: If skill needs automated processing or validation (provide .sh + .ps1 for cross-platform)
- `references/`: If SKILL.md would exceed 500 lines
- `templates/`: If skill provides reusable templates
- `assets/`: If skill needs examples, checklists, images, or data files

### Step 5: Write SKILL.md

**Required YAML frontmatter:**

```yaml
---
name: skill-name                    # Required: matches directory, lowercase, hyphens only
description: "[Actions]. Use when..." # Required: 1-1024 chars (150-300 optimal)
license: MIT
metadata:                            # Optional
  author: Your Name
  version: "1.0"
  last_updated: "2026-02-08"
---
```

**Required sections:**

1. **# Skill Name** - Title matching the skill name
2. **## Overview** - 2-3 sentences explaining what the skill does
3. **## When to Use** - Bullet list of 3-5 specific scenarios
4. **## Prerequisites** - Required tools, packages, versions (or "None")
5. **## Instructions** - Step-by-step with numbered sections, code examples
6. **## Examples** - At least 2 examples with input/output
7. **## Edge Cases** - 2-3 unusual situations and handling
8. **## Error Handling** - Common errors and solutions

**Optional sections:**

- **## Scripts** - Usage of automation scripts (if using scripts/)
- **## References** - Links to detailed documentation (if using references/)
- **## Validation** - How to validate usage

**Key requirements:**

- Keep under 500 lines total
- Use clear, imperative language
- Provide concrete examples
- Document assumptions
- Include error handling guidance
- Set license to "FPT Software Internal Use, FPT Software Intellectual Property"

### Step 6: Write Scripts (If Needed)

**Cross-platform rule: Always provide both script formats (Bash + PowerShell ONLY):**

| Format | File | Runs On | When to Use |
|--------|------|---------|-------------|
| Bash | `script.sh` | macOS, Linux, WSL, Git Bash | Unix-native users, CI/CD pipelines |
| PowerShell | `script.ps1` | Windows (5.1+), cross-platform (7+) | Windows-native users, Windows CI |

**⚠️ Non-standard script formats in `scripts/` directory:** `.py`, `.rb`, `.js`, `.ts`, `.pl`, or any other language besides `.sh` and `.ps1` will be **reported as warnings** during validation. **Do NOT automatically remove or convert these files** — users may have created them intentionally. Always ask the user before taking action on non-standard scripts.

**Bash script (macOS/Linux/WSL):**

```bash
#!/usr/bin/env bash
# Script description.
# Usage: bash scripts/script.sh <input> [--option value]
# Platforms: macOS, Linux, WSL, Git Bash
# Requirements: Bash 4.0+

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename "$0") <input>" >&2
    exit 2
fi

INPUT="$1"
if [[ ! -f "$INPUT" ]]; then
    echo "Error: File not found: $INPUT" >&2
    exit 1
fi

echo "Processing $INPUT..."
# Your logic here
echo "Done!"
```

**PowerShell script (Windows/cross-platform):**

```powershell
<#
.SYNOPSIS
    Script description.
.PARAMETER Input
    Input file path (required).
.EXAMPLE
    .\scripts\script.ps1 -Input input.txt
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Input
)

if (-not (Test-Path -Path $Input -PathType Leaf)) {
    Write-Error "File not found: $Input"
    exit 1
}

Write-Host "Processing $Input..."
# Your logic here
Write-Host "Done!"
```

**Key requirements for all scripts:**

- **Bash**: Use `set -euo pipefail`, quote variables, use `[[ ]]` for conditionals, add shebang `#!/usr/bin/env bash`
- **PowerShell**: Use `[CmdletBinding()]` and `param()`, use `Test-Path` for file checks, support `-Verbose`
- **Both formats**: Consistent argument names, same exit codes, equivalent functionality, usage docs

### Step 7: Create References (If Needed)

**When to use references/:**

- SKILL.md exceeds 400 lines
- Detailed technical documentation needed
- Multiple complex topics to cover
- Large examples or data

**Keep references focused:**

- One topic per file
- Clear headings
- Concrete examples
- Referenced from SKILL.md

### Step 8: Validate

**Automated validation (recommended):**

```bash
bash scripts/validate-skill.sh ./skill-name         # macOS/Linux/WSL
.\scripts\validate-skill.ps1 -Path ./skill-name     # Windows PowerShell
```

### Step 9: Report Completion

After validation, report to the user with:

1. **Validation result**: Pass/fail with check count
2. **Files created/modified**: List all skill files
3. **Non-standard scripts warning**: If `.py`, `.rb`, `.js`, `.ts`, `.pl` or other non-standard scripts are found in `scripts/`, list them and **ask the user** whether to: (a) convert to .sh/.ps1 pairs, (b) keep as-is, or (c) move to a different directory. **Never remove or convert without explicit user confirmation.**
4. **Key decisions**: Name chosen, scope (minimal/standard/complex), any assumptions made
5. **Next steps**: How to install, test, or iterate on the skill

## Examples

### Example 1: Minimal Skill - Code Review

**Directory structure:**

```
code-review/
└── SKILL.md (with frontmatter, instructions, examples)
```

**Key elements:** Clear description, step-by-step instructions, concrete examples

### Example 2: Skill with Scripts - CSV Processing

**Directory structure:**

```
csv-processing/
├── SKILL.md
└── scripts/
    ├── convert.sh       # Bash (macOS/Linux/WSL)
    ├── convert.ps1      # PowerShell (Windows)
    ├── validate.sh      # Bash validation
    └── validate.ps1     # PowerShell validation
```

**Key elements:** Both script formats (.sh, .ps1) for cross-platform support, usage instructions, error handling

### Example 3: Complex Skill - This Skill

**Directory structure:**

```
agent-skill-creation/
├── SKILL.md (<500 lines)
├── scripts/
│   ├── generate-skill.sh, generate-skill.ps1
│   └── validate-skill.sh, validate-skill.ps1
├── references/ (detailed guidance)
├── templates/ (ready-to-use)
└── assets/ (examples, checklists)
```

See [assets/examples/](assets/examples/) for complete working examples and [references/advanced-patterns.md](references/advanced-patterns.md) for more patterns.

## Edge Cases

### Case 1: Large Documentation (2000+ lines)

**Handling**: Extract core instructions for SKILL.md (<500), move details to references/, link from main file

### Case 2: Platform-Specific Requirements

**Handling**: Provide both script formats (.sh, .ps1). Use Bash for macOS/Linux/WSL, PowerShell for Windows. Document platform notes in Prerequisites

### Case 3: Complex Dependencies

**Handling**: List in Prerequisites with versions, provide install commands, create validation script

### Case 4: No Clear Keywords

**Handling**: Include synonyms, problem symptoms, technical and non-technical terms in description

## Error Handling

### Invalid Skill Name

**Solution**: Convert to lowercase, replace spaces/underscores with hyphens, validate with `grep -E '^[a-z0-9]+(-[a-z0-9]+)*$'`

### Description Too Vague

**Solution**: Add 2-4 action verbs, "Use when..." scenarios, 3-5 keywords, aim for 150-300 chars

### SKILL.md Too Long (>500 lines)

**Solution**: Move detailed content to references/, keep essential instructions in main file

### Missing Required Fields

**Solution**: Add name and description to frontmatter, validate YAML syntax (spaces, not tabs)

### Script Not Cross-Platform

**Solution**: Always provide both formats: Bash (.sh) for macOS/Linux/WSL, PowerShell (.ps1) for Windows. Ensure equivalent functionality and consistent argument names across both formats. **Report** any non-standard scripts (.py, .rb, .js, etc.) as warnings and **ask the user** whether to convert or keep them before making changes

### External References

**Solution**: Copy content into skill directory (references/ or assets/), use relative paths

## Quality Checklist

**Before finalizing, verify:**

**Structure:**

- [ ] Name matches directory (lowercase, hyphens only, 1-64 chars)
- [ ] Valid YAML frontmatter with required fields (name, description)
- [ ] SKILL.md under 500 lines
- [ ] Self-contained (no dependencies on external files outside skill directory)

**Content:**

- [ ] Description is comprehensive (actions + use cases + keywords, 150-300 chars)
- [ ] Clear instructions with step-by-step guidance
- [ ] At least 2 examples with input/output
- [ ] Edge cases documented (2-3 minimum)
- [ ] Error handling included with solutions

**Scripts (if present):**

- [ ] Non-standard scripts in scripts/ (.py, .rb, .js, .ts, .pl) reported — ask user before removing/converting
- [ ] Both formats provided: .sh and .ps1
- [ ] Bash: uses `set -euo pipefail`, quotes variables, has shebang `#!/usr/bin/env bash`
- [ ] PowerShell: uses `[CmdletBinding()]` and `param()`, supports `-Verbose`
- [ ] Both formats: consistent arguments, same exit codes, equivalent functionality
- [ ] Usage documentation in each script (docstring/comments/help block)
- [ ] Error messages are clear across all formats

**References (if present):**

- [ ] Referenced from SKILL.md
- [ ] One topic per file
- [ ] Clear structure with headings

## Resources

- **References:** [best-practices.md](references/best-practices.md), [advanced-patterns.md](references/advanced-patterns.md), [troubleshooting.md](references/troubleshooting.md)
- **Templates:** [skill-template.md](templates/skill-template.md), [script-template.sh](templates/script-template.sh), [script-template.ps1](templates/script-template.ps1), [frontmatter-examples.yaml](templates/frontmatter-examples.yaml)
- **Scripts:** [generate-skill.sh](scripts/generate-skill.sh) / [.ps1](scripts/generate-skill.ps1), [validate-skill.sh](scripts/validate-skill.sh) / [.ps1](scripts/validate-skill.ps1)
- **Assets:** [examples/](assets/examples/), [checklists/](assets/checklists/)

## Tips for Success

1. **Start simple**: Minimal structure first, add complexity only if needed
2. **Be specific**: Concrete examples over abstract descriptions
3. **Test early**: Validate as you build, don't wait until the end
4. **Focus on discovery**: Description is critical for skill activation
5. **Think progressive**: Keep SKILL.md concise, use references/ for details
6. **Stay self-contained**: No external dependencies outside skill directory
7. **Use templates**: Start with templates/skill-template.md
8. **Validate often**: Run validation after each major change
