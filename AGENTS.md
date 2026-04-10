# Agent Personas and Protocols

## 1. Overview
This project utilizes an agentic workflow. All agents must adhere to the `docs/` guidelines and use the `main` branch for all PRs.

## 2. Project Structure

```text
├── agents/                  # Agent persona definitions
│   └── business-analyst.md
├── skills/                  # Shared cross-platform agent skills
│   ├── gen-requirement-development/
│   ├── gen-requirement-clarification/
│   ├── gen-coding-plan/
│   ├── gen-code-implementation/
│   ├── gen-code-review/
│   ├── gen-coding-standards/
│   ├── gen-architecture-design/
│   ├── gen-technical-detailed-design/
│   ├── gen-codebase-assessment/
│   ├── gen-project-consistency-analysis/
│   ├── gen-project-ground-rules-setup/
│   ├── gen-security-review/
│   ├── gen-git-commit/
│   ├── gen-git-command-guidelines/
│   ├── gen-nextjs-mockup/
│   ├── gen-nuxtjs-mockup/
│   ├── gen-agent-skill-creation/
│   ├── sec-compliance-standards/
│   └── sec-ip-protection/
├── .claude/skills/          # Claude Code-specific skills
│   ├── gen-agent-skill-creation/
│   ├── gen-update-agent-file/
│   └── git-commit/
├── src/nightlife_cli/       # Main CLI package (Python)
├── docs/                    # Documentation (DocFX)
├── templates/               # Agent file templates
└── .github/workflows/       # CI/CD pipelines
```

## 3. Agent Definitions

### Business Analyst
* **Primary Role:** Bridges the gap between business stakeholders and the development team. Activates when the user needs help with requirements gathering, user story writing, acceptance criteria, backlog management, or business process analysis.
* **Context Scope:** Requirements, specifications, and project documentation in `docs/`.
* **Skills:** `gen-requirement-development`, `gen-requirement-clarification`, `gen-coding-plan`, `gen-project-consistency-analysis`
* **Constraint:** Must validate requirements against project ground-rules before finalising. Flags scope creep or conflicting requirements immediately.

## 4. Communication Protocols
* **Handoffs:** When requirements are approved and ready for implementation, the Business Analyst hands off to implementation by producing a `tasks.md` via `gen-coding-plan`.
* **Validation:** All outputs must be validated against project ground-rules and the `docs/` specifications before completion.

## 5. Available Skills

| Skill | Description | Location |
|---|---|---|
| gen-requirement-development | Creates feature specifications from natural language descriptions with testable requirements and acceptance criteria | skills/ |
| gen-requirement-clarification | Reviews and clarifies existing specifications by identifying underspecified areas and asking targeted questions | skills/ |
| gen-coding-plan | Generates actionable, dependency-ordered tasks.md files from design artifacts | skills/ |
| gen-code-implementation | Executes feature implementation by processing tasks.md files with TDD approach | skills/ |
| gen-code-review | Reviews source code for simplicity, maintainability, and quality | skills/ |
| gen-coding-standards | Generates comprehensive coding standards and conventions documentation | skills/ |
| gen-architecture-design | Creates comprehensive system architecture documentation using C4 model and ADRs | skills/ |
| gen-technical-detailed-design | Generates technical detailed design artifacts including data models and API contracts | skills/ |
| gen-codebase-assessment | Analyzes existing codebases to understand architecture, patterns, and conventions | skills/ |
| gen-project-consistency-analysis | Performs cross-artifact consistency analysis across spec.md, design.md, and tasks.md | skills/ |
| gen-project-ground-rules-setup | Creates or updates project ground-rules documentation with versioned principles | skills/ |
| gen-security-review | Reviews source code for security vulnerabilities including OWASP Top 10 | skills/ |
| gen-git-commit | Generates well-structured git commit messages following conventional commit standards | skills/ |
| gen-git-command-guidelines | Provides git command guidelines, branching strategies, and workflow best practices | skills/ |
| gen-nextjs-mockup | Creates interactive UI mockups using Next.js 16, React 19, and Tailwind CSS 4 | skills/ |
| gen-nuxtjs-mockup | Creates interactive UI mockups using Nuxt 4, Vue 3, and Tailwind CSS 4 | skills/ |
| gen-agent-skill-creation | Generates and updates agent skills following the Agent Skills specification | skills/ |
| sec-compliance-standards | Performs GDPR, HIPAA, SOC2, and PCI-DSS compliance checks and audit readiness reviews | skills/ |
| sec-ip-protection | Performs code origin verification, license scanning, and IP contamination prevention | skills/ |
| gen-update-agent-file | Generates and updates CLAUDE.md and AGENTS.md based on real project structure | .claude/skills/ |
| git-commit | Generates well-structured git commit messages following conventional commits | .claude/skills/ |

## 6. Recent Changes

- `98cb5a0` fix: release process fix
- `3e79170` fix: fix release wf
- `ade554a` feat: add platforms
- `34d9f5b` fix(release): scripts
- `66adf72` fix(skills): removed some skills

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
