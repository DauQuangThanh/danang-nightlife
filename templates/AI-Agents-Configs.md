# AI Coding Agents & IDEs: Project-Level Configuration Reference

> Comprehensive report of project-level configuration files, folder structures, instruction files, custom agents, skills, and other settings for 25 AI coding agent platforms and IDEs.
>
> Last updated: 2026-04-10

---


## Cross-Platform Comparison Matrix

The AI coding agent ecosystem as of **April 10, 2026**, has moved toward a **"Modular Persona" architecture**. Under the **Agentic AI Foundation (AAIF)** standards, the "MCP Config" (Model Context Protocol) is now considered a lower-level transport setting, while the **Custom Agents Folder** has become the primary interface for developers to define specialized subagents and task-specific personas.

### Cross-Platform Comparison Matrix (April 2026)

| Platform | Project Config Folder | Context Instruction File | Custom Agents Folder | Skills Directory |
| :--- | :--- | :--- | :--- | :--- |
| **Amp** | `.amp/` | `AGENTS.md` | `.amp/agents/` | `.amp/skills/` |
| **Antigravity** | `.agent/` | `AGENTS.md` | `.agent/workflows/` | `.agent/skills/` |
| **Augment Code** | `.augment/` | `AGENTS.md` | `.augment/agents/` | `.augment/skills/` |
| **Claude Code (v2.1)** | `.claude/` | `CLAUDE.md` | `.claude/agents/` | `.claude/skills/` |
| **Cline (v3.0)** | `.cline/` | `AGENTS.md` | `.cline/agents/` | `.cline/skills/` |
| **CodeBuddy** | `.codebuddy/` | `AGENTS.md` | `.codebuddy/agents/` | `.codebuddy/skills/` |
| **Codex CLI** | `.codex/` | `AGENTS.md` | `.codex/agents/` | `.codex/skills/` |
| **Cursor** | `.cursor/` | `AGENTS.md` | `.cursor/agents/` | `.cursor/skills/` |
| **Forge** | `.forge/` | `AGENTS.md` | `.forge/agents/` | `.forge/skills/` |
| **Gemini CLI** | `.gemini/` | `AGENTS.md` | `.gemini/agents/` | `.gemini/skills/` |
| **GitHub Copilot (IDE)** | `.github/` | `AGENTS.md` | `.github/agents/` | `.github/skills/` |
| **GitHub Copilot CLI** | `.copilot/` | `AGENTS.md` | `.copilot/agents/` | `.copilot/skills/` |
| **IBM Bob** | `.bob/` | `AGENTS.md` | `.bob/agents/` | `.bob/skills/` |
| **Junie** | `.junie/` | `AGENTS.md` | `.junie/agents/` | `.junie/skills/` |
| **Kilo Code** | `.kilocode/` | `AGENTS.md` | `.kilocode/agents/` | `.kilocode/skills/` |
| **Kiro** | `.kiro/` | `AGENTS.md` | `.kiro/agents/` | `.kiro/skills/` |
| **Mistral Vibe** | `.vibe/` | `AGENTS.md` | `.vibe/agents/` | `.vibe/skills/` |
| **opencode** | `.opencode/` | `AGENTS.md` | `.opencode/agents/` | `.opencode/skills/` |
| **Pi Agent** | `.omp/` | `AGENTS.md` | `.omp/agents/` | `.omp/skills/` |
| **Qoder** | `.qoder/` | `AGENTS.md` | `.qoder/agents/` | `.qoder/skills/` |
| **Qwen Code** | `.qwen/` | `AGENTS.md` | `.qwen/agents/` | `.qwen/skills/` |
| **Roo Code** | `.roo/` | `AGENTS.md` | `.roo/agents/` | `.roo/skills/` |
| **Tabnine** | `.tabnine/` | `AGENTS.md` | `.tabnine/agents/` | `.tabnine/skills/` |
| **Trae** | `.trae/` | `AGENTS.md` | `.trae/agents/` | `.trae/skills/` |
| **Windsurf** | `.windsurf/` | `AGENTS.md` | `.windsurf/agents/` | `.windsurf/skills/` |

---

### Key April 2026 Adjustments

1. **"Modular Persona" Architecture:** The ecosystem has converged on the **Custom Agents Folder** as the primary developer interface for specialized subagents. MCP config is now treated as a lower-level transport concern separate from agent persona definition.
2. **Instruction Pathing:** All platforms have shifted toward a "Hidden Folder" strategy. Even universal files like `AGENTS.md` are now preferred within the `.claude/`, `.qoder/` etc. directories to prevent root-level clutter, though most maintain a fallback check for the project root.
3. **Claude Code v2.1:** Introduces "lazy loading" for MCP tools. Custom subagents are defined as `.agent.md` files in `.claude/agents/` — the agent picks the best subagent based on its description to delegate tasks.
4. **GitHub Copilot v1.110:** Standardized "Background Agent" settings. `.github/agents/*.agent.md` files support a `mode` field and `@` invocation in chat. Nested instructions in `.github/instructions/` enable directory-specific logic in large monorepos.
5. **Roo Code (new entry):** Forked from Kilo Code, specializing in "Modes" architecture. Custom agents are created by adding specialized rules to directories like `.roo/rules-architect/`, allowing the agent to switch its entire personality and toolset.

---

### Platform Descriptions & Custom Agent Architectures

Based on the **GitHub Spec Kit** integration registry, platforms now handle custom agents via specific protocol classes:

- **Claude Code (`claude-code`):** Uses a `MarkdownIntegration` class. Custom agents (subagents) are defined as `.agent.md` files in `.claude/agents/`. The agent uses each subagent's description to decide when to delegate tasks automatically.
- **Qoder (`qodercli`):** Prioritizes "Project Commands" in `.qoder/commands/` which act as ephemeral agents for tasks like "Validate Config" or "API Check".
- **GitHub Copilot (`copilot`):** Supports Markdown-based `.agent.md` files in `.github/agents/`. Invoked with the `@` syntax in chat; supports a `mode` field to define the subagent's primary reasoning style.
- **Cursor (`cursor-agent`):** Utilizes `.cursor/commands/` for Markdown-based instructions alongside `.mdc` files that trigger automatically based on file-glob patterns, effectively creating "Context-Aware Agents".
- **Windsurf:** Features "Cascade Memories" where rules and custom agent behaviors are stored in `.windsurf/rules/`. Supports "always-on" global rules versus directory-specific `AGENTS.md` triggers.
- **Cline / Roo Code:** Focus on "Modes" (e.g., Architect, Code, Debug). Custom agents are created by adding specialized rules to directories like `.roo/rules-architect/`, allowing the agent to switch its entire personality and toolset.
- **Gemini CLI (`gemini-cli`):** A `TomlIntegration` agent. Stores custom behavior policies in `.gemini/policies/` and uses `{{args}}` for parameter injection in commands.
- **Codex CLI (`codex`):** A `SkillsIntegration` agent. Custom agents are standalone TOML files in `.codex/agents/` or personal agents in `~/.codex/agents/`, defining specific `developer_instructions` and allowed tools.
- **Forge:** A custom `IntegrationBase` platform where agents are defined directly in `forge.yaml`. Supports `hide_content` for "Background Helper" agents that assist the main thread without cluttering the UI.
- **Antigravity:** Specializes in "Workflows" defined in `.agent/workflows/`, which are multi-step agentic sequences managed via Markdown files.