---
name: gen-update-agent-file
description: Generates and updates CLAUDE.md and AGENTS.md files based on real project structure, technologies, agents, and skills. Use when setting up agent configuration, syncing agent files with project state, or when user mentions CLAUDE.md, AGENTS.md, agent file update, or project context sync.
license: MIT
metadata:
  author: Danang Nightlife Team
  version: "1.0"
  last_updated: "2026-04-10"
---

# Update Agent Configuration Files

## Overview

Scans the real project structure, technologies, dependencies, agents, and skills to generate or update `CLAUDE.md` and `AGENTS.md` files. If existing files follow a template format (with `<!-- TEMPLATE START -->` markers or `{{PLACEHOLDER}}` tokens), the skill preserves the template structure and fills placeholders with real project data.

## When to Use

- Setting up a new project's agent configuration files
- Syncing CLAUDE.md / AGENTS.md after project structure changes (new skills, agents, dependencies)
- Converting template-based agent files to real project-specific files
- Onboarding a project to multi-agent workflows
- When the user asks to "update agent files", "refresh CLAUDE.md", or "sync AGENTS.md"

## Prerequisites

- A project repository with source code
- Access to read project files (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
- Optional: existing `templates/agent-file-template.md` or `templates/AI-Agents-Configs.md` for template-aware generation

## Instructions

### Step 1: Scan the Project

Gather real project data by inspecting the following (in parallel where possible):

**1a. Project identity and metadata:**
- Read `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `*.csproj`, or equivalent
- Extract: project name, version, description, language, framework

**1b. Directory structure:**
- Run `ls` or use Glob on the project root to capture top-level layout
- Identify key directories: `src/`, `lib/`, `app/`, `pages/`, `components/`, `tests/`, `docs/`, `scripts/`
- Build a concise tree (max 3 levels deep, omit `node_modules`, `.git`, `__pycache__`, `.venv`)

**1c. Technology stack:**
- Parse dependency files for frameworks and libraries (e.g., React, Next.js, FastAPI, Django, Express)
- Check for config files: `tsconfig.json`, `tailwind.config.*`, `.eslintrc.*`, `Dockerfile`, `docker-compose.yml`
- Note build tools: Vite, Webpack, Hatch, Poetry, Cargo, Maven, Gradle

**1d. Agent ecosystem:**
- Scan for agent definitions in: `agents/`, `.claude/agents/`, `.github/agents/`, `.cursor/agents/`
- Read each agent file's frontmatter (name, description) and list of skills referenced
- Scan for skills in: `skills/`, `.claude/skills/`, `.github/skills/`
- Read each skill's SKILL.md frontmatter (name, description)

**1e. Git and CI/CD:**
- Check `.github/workflows/` for CI pipelines
- Read `CODEOWNERS` if present
- Note branch strategy from recent git log

**1f. Existing agent files:**
- Check for `CLAUDE.md` and `AGENTS.md` at project root
- Check for templates in `templates/` directory (look for `agent-file-template.md`, `AI-Agents-Configs.md`)
- Determine if existing files are templates (contain `<!-- TEMPLATE -->` markers or `{{PLACEHOLDER}}` tokens)

### Step 2: Detect Template Mode

Check whether to use template-guided generation or freeform generation:

**Template mode** (if ANY of these are true):
- `templates/agent-file-template.md` exists → use it as the AGENTS.md template
- Existing `CLAUDE.md` or `AGENTS.md` contains `<!-- TEMPLATE START -->` / `<!-- TEMPLATE END -->` markers
- Existing files contain `{{PLACEHOLDER}}` tokens

**Freeform mode** (otherwise):
- Generate files from scratch using the standard format below

### Step 3: Generate CLAUDE.md

Write or update `CLAUDE.md` at the project root. This file provides project context to Claude Code.

**Standard CLAUDE.md structure:**

```markdown
# Project: {project_name}

{project_description}

## Tech Stack

- **Language:** {language} {version}
- **Framework:** {framework}
- **Build Tool:** {build_tool}
- **Package Manager:** {package_manager}
- **Key Dependencies:** {dep1}, {dep2}, {dep3}

## Project Structure

```text
{directory_tree — max 3 levels, key dirs only}
```

## Development Commands

- **Install:** `{install_command}`
- **Dev server:** `{dev_command}`
- **Build:** `{build_command}`
- **Test:** `{test_command}`
- **Lint:** `{lint_command}`

## Coding Conventions

- {convention_1 — inferred from linter configs, tsconfig, pyproject, etc.}
- {convention_2}

## Important Notes

- {note_1 — e.g., monorepo structure, env vars needed, special setup}
```

**Rules:**
- Only include sections with real data — omit empty sections
- Keep commands accurate (verify they exist in scripts/config)
- Do NOT fabricate conventions — only include what's provable from config files
- If a `CLAUDE.md` already exists and is NOT a template, preserve any `<!-- MANUAL ADDITIONS START -->` blocks

### Step 4: Generate AGENTS.md

Write or update `AGENTS.md` at the project root. This file defines agent personas and protocols.

**If template mode** — read `templates/agent-file-template.md` and replace placeholders:

| Placeholder | Replace With |
|---|---|
| `{{SPEC_DIR}}` | Path to specs/docs directory (e.g., `docs/`) |
| `{{AGENT_NAME}}` | One section per discovered agent from `agents/` directory |
| `{{DOCS_PATH}}` | Path to documentation directory |
| `{{DESIGN_SPEC}}` | Design spec file path if found, else remove line |
| `{{TEST_SUITE}}` | Test command or framework |
| `{{CONDITION}}` | Inferred handoff conditions from agent descriptions |
| `{{METHOD}}` | Communication method (e.g., "updating task status") |
| `[ACTUAL STRUCTURE]` | Real directory tree |
| `[LAST 3 FEATURES AND WHAT THEY ADDED]` | From `git log --oneline -10` |

Preserve `<!-- MANUAL ADDITIONS START -->` / `<!-- MANUAL ADDITIONS END -->` blocks unchanged.

**If freeform mode** — generate using this structure:

```markdown
# Agent Personas and Protocols

## 1. Overview

This project utilizes an agentic workflow. All agents must adhere to the project guidelines.

## 2. Project Structure

```text
{directory_tree}
```

## 3. Agent Definitions

### {Agent Name}
* **Primary Role:** {from agent frontmatter description}
* **Skills:** {list of skills the agent references}
* **Context Scope:** {inferred from skill types}

{repeat for each agent in agents/ directory}

## 4. Available Skills

| Skill | Description |
|---|---|
| {skill-name} | {skill description from frontmatter} |

{repeat for each skill in skills/ and .claude/skills/}

## 5. Communication Protocols

* **Handoffs:** Agents delegate tasks by invoking the appropriate skill.
* **Validation:** All outputs must be validated against project ground rules before completion.

## 6. Recent Changes

{last 3-5 meaningful commits from git log}

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
```

### Step 5: Validate Output

After generating both files, verify:

1. **No fabricated data** — every section references real files, real commands, real agents
2. **No leftover placeholders** — grep for `{{` in generated files; there should be zero matches
3. **Manual blocks preserved** — if updating existing files, `<!-- MANUAL ADDITIONS -->` content is intact
4. **Accuracy** — spot-check 2-3 commands or paths mentioned in the files
5. **Conciseness** — CLAUDE.md should be under 150 lines; AGENTS.md under 200 lines

### Step 6: Report Changes

Summarize what was generated/updated:
- Files created or modified
- Template mode or freeform mode used
- Number of agents and skills discovered
- Any sections omitted due to missing data
- Suggested manual additions the user may want to make

## Examples

### Example 1: Python CLI Project (This Project)

**Scenario:** The danang-nightlife project has `pyproject.toml`, `agents/` with one agent, `skills/` with 20 skills, and a template at `templates/agent-file-template.md`.

**Action:** Template mode is detected. Scan reveals Python 3.11+, Typer/Rich CLI, Hatch build system. The template placeholders are replaced with real data.

**CLAUDE.md output (excerpt):**

```markdown
# Project: nightlife-cli

Nightlife CLI — A framework for Spec-Driven Development (SDD).

## Tech Stack

- **Language:** Python 3.11+
- **Framework:** Typer + Rich
- **Build Tool:** Hatch
- **Key Dependencies:** typer, rich, httpx, platformdirs
```

**AGENTS.md output (excerpt):**

```markdown
### Business Analyst
* **Primary Role:** Bridges the gap between business stakeholders and the development team.
* **Skills:** gen-requirement-development, gen-requirement-clarification, gen-coding-plan, gen-project-consistency-analysis
* **Context Scope:** Requirements, specifications, and project documentation
```

### Example 2: Fresh Project with No Templates

**Scenario:** A new Node.js project with `package.json`, no agents/ directory, no templates.

**Action:** Freeform mode. Generates minimal CLAUDE.md from package.json data and a skeleton AGENTS.md with empty agent definitions section and a note to add agents.

**CLAUDE.md output (excerpt):**

```markdown
# Project: my-api

REST API service for user management.

## Tech Stack

- **Language:** TypeScript 5.x
- **Framework:** Express.js
- **Build Tool:** tsc
- **Key Dependencies:** express, prisma, zod, jsonwebtoken
```

## Edge Cases

### Case 1: No Dependency File Found

**Handling:** Fall back to scanning file extensions (`.py`, `.ts`, `.rs`, `.go`) to infer language. Set framework and build tool to "Unknown — please specify" and flag this in the report.

### Case 2: Template with Custom Placeholders

**Handling:** If the template contains placeholders beyond the standard set (e.g., `{{CUSTOM_FIELD}}`), leave them as-is and list them in the completion report so the user can fill them manually.

### Case 3: Existing Files with Manual Additions

**Handling:** Parse `<!-- MANUAL ADDITIONS START -->` / `<!-- MANUAL ADDITIONS END -->` blocks. Regenerate everything outside those blocks, but preserve manual content exactly as-is.

## Error Handling

### Error: Permission Denied Reading Files

**Cause:** Agent lacks read access to certain directories.

**Solution:** Skip inaccessible paths, note them in the report, and generate files from available data.

### Error: Conflicting Agent Definitions

**Cause:** Same agent name exists in multiple directories (e.g., `agents/` and `.claude/agents/`).

**Solution:** Prefer platform-specific directory (`.claude/agents/` for Claude Code). List both in the report and ask the user which to use.

### Error: Template Parsing Failure

**Cause:** Malformed template with unclosed markers or invalid YAML.

**Solution:** Fall back to freeform mode and warn the user that the template could not be parsed.

## Quality Checklist

Before considering this task complete:

- [ ] CLAUDE.md exists at project root with accurate tech stack
- [ ] AGENTS.md exists at project root with all discovered agents and skills
- [ ] No `{{PLACEHOLDER}}` tokens remain in generated files
- [ ] Manual addition blocks are preserved if updating existing files
- [ ] All referenced file paths and commands are verified to exist
- [ ] Report summarizes what was generated and any gaps

## Tips

1. **Run scan in parallel**: Steps 1a-1f are independent — execute them concurrently for speed
2. **Verify before writing**: Always confirm a command or path exists before including it in the output
3. **Preserve user work**: Never overwrite `<!-- MANUAL ADDITIONS -->` blocks
4. **Keep it concise**: Agent files should be scannable, not exhaustive — link to docs for details
5. **Flag unknowns**: It's better to say "Unknown — please specify" than to fabricate data
