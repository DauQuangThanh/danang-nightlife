# Template Guidelines for Agent Files

## Overview

This reference documents how to detect, parse, and fill template-based `CLAUDE.md` and `AGENTS.md` files. Templates allow teams to standardize agent file structure across projects while letting the skill fill in project-specific data.

## Template Detection

### Markers

Templates are identified by the presence of any of these patterns:

| Pattern | Meaning |
|---|---|
| `<!-- TEMPLATE START -->` ... `<!-- TEMPLATE END -->` | Entire file is a template |
| `{{PLACEHOLDER_NAME}}` | Individual fields to replace |
| `[ACTUAL STRUCTURE]` | Bracketed instructions to replace with real data |
| `[LAST 3 FEATURES AND WHAT THEY ADDED]` | Bracketed instructions for dynamic content |

### Detection Order

1. Check for `<!-- TEMPLATE START -->` markers first (strongest signal)
2. Check for `{{` double-brace placeholders
3. Check for `[ALL CAPS INSTRUCTION]` patterns in code blocks
4. If none found → freeform mode

## Standard Placeholders

### AGENTS.md Template Placeholders

Based on `templates/agent-file-template.md`:

| Placeholder | Description | How to Fill |
|---|---|---|
| `{{SPEC_DIR}}` | Specifications/docs directory | Scan for `docs/`, `specs/`, `specifications/` directories |
| `{{AGENT_NAME}}` | Agent persona name | Read from `agents/*.md` frontmatter `name:` field |
| `{{DOCS_PATH}}` | Documentation path | Use path to `docs/` or primary documentation directory |
| `{{DESIGN_SPEC}}` | Design specification file | Look for `design.md`, `architecture.md`, `DESIGN.md` |
| `{{TEST_SUITE}}` | Test command or framework | Parse from `package.json` scripts, `pyproject.toml`, or Makefile |
| `{{CONDITION}}` | Handoff trigger condition | Infer from agent descriptions and skill relationships |
| `{{METHOD}}` | Communication method | Default: "updating task status and referencing the relevant skill" |
| `[ACTUAL STRUCTURE]` | Project directory tree | Generate using `tree` or `find` (max 3 levels) |
| `[LAST 3 FEATURES...]` | Recent feature commits | Extract from `git log --oneline` filtering for feat/feature commits |

### CLAUDE.md Placeholders (If Templated)

| Placeholder | Description | How to Fill |
|---|---|---|
| `{{PROJECT_NAME}}` | Project name | From `package.json` name, `pyproject.toml` [project] name, etc. |
| `{{PROJECT_DESCRIPTION}}` | One-line description | From dependency file description field |
| `{{LANGUAGE}}` | Primary programming language | Detect from file extensions and dependency files |
| `{{FRAMEWORK}}` | Primary framework | Parse from dependencies (React, Next.js, FastAPI, etc.) |
| `{{BUILD_TOOL}}` | Build system | Detect: Hatch, Poetry, npm, Vite, Webpack, Cargo, etc. |

## Manual Addition Blocks

### Purpose

Manual addition blocks allow users to add custom content that survives regeneration:

```markdown
<!-- MANUAL ADDITIONS START -->
Any content here is preserved during updates.
<!-- MANUAL ADDITIONS END -->
```

### Rules

1. **Never modify** content between these markers
2. **Always preserve** marker comments exactly as-is (including whitespace)
3. If markers don't exist in a new file, **add them** at the end of each generated file
4. If the file has multiple manual blocks, preserve all of them

### Parsing Strategy

```
1. Read entire file content
2. Find all <!-- MANUAL ADDITIONS START --> ... <!-- MANUAL ADDITIONS END --> pairs
3. Store their content and position (which section they appear in)
4. Regenerate everything outside manual blocks
5. Re-insert manual blocks at their original positions
```

## Multi-Platform Awareness

When generating `AGENTS.md`, be aware that different AI coding platforms use different paths:

- **Claude Code:** `.claude/` config, `CLAUDE.md` instruction file
- **GitHub Copilot:** `.github/` config, `AGENTS.md` or `.github/copilot-instructions.md`
- **Cursor:** `.cursor/` config, `AGENTS.md`
- **Most others:** `AGENTS.md` at project root

The skill generates **both** `CLAUDE.md` (Claude-specific) and `AGENTS.md` (cross-platform) to maximize compatibility.

## Filling Strategies

### When Data is Missing

| Situation | Strategy |
|---|---|
| No dependency file found | Infer language from file extensions, mark framework as "Unknown" |
| No agents directory | Create empty Agent Definitions section with a comment to add agents |
| No skills directory | Omit skills table, add note about no skills configured |
| No test command found | Set test command to "No test command configured" |
| No CI/CD detected | Omit CI/CD section entirely |

### When Data Conflicts

| Situation | Strategy |
|---|---|
| Multiple dependency files | Use the primary one (package.json for JS, pyproject.toml for Python) |
| Agent in multiple dirs | Prefer platform-specific dir (.claude/agents/ for Claude Code) |
| Duplicate skill names | List both with their full paths to disambiguate |
