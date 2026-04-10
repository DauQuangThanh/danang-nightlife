# 📦 Installation Guide

**Get started with Danang Nightlife in minutes.**

---

## ⚙️ What You Need

Before installing, make sure you have:

| Requirement | Description |
| ------------- | ------------- |
| **Operating System** | Linux, macOS, or Windows (PowerShell supported) |
| **AI Assistant** | Any [supported agent](../README.md#-supported-ai-agents) — Claude Code, GitHub Copilot, Gemini CLI, Cursor, Windsurf, and 20 more |
| **Package Manager** | [uv](https://docs.astral.sh/uv/) |
| **Python** | [Version 3.11 or higher](https://www.python.org/downloads/) |
| **Version Control** | [Git](https://git-scm.com/downloads) |

---

## 🚀 Installation Options

### Option 1: Create a New Project

The easiest way to start:

```bash
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <PROJECT_NAME>
```

### Option 2: Initialize in Current Directory

Already have a project folder?

```bash
# Method 1: Using dot notation
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init .

# Method 2: Using --here flag
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init --here
```

### 🤖 Choose Your AI Agent

Specify which AI assistant to use with `--ai`. See the full list of [supported agents](../README.md#-supported-ai-agents) for all 25 platform keys.

```bash
# Claude Code
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai claude

# Gemini CLI
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai gemini

# GitHub Copilot (IDE)
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai copilot

# GitHub Copilot CLI
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai copilot-cli

# Cursor
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai cursor-agent

# Multiple agents at once
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai claude,copilot,gemini
```

### 🔧 Script Type (Python)

All automation scripts are now Python-based for cross-platform compatibility:

**Default behavior:**

- 🐧 All platforms → Python (`.py`)
- 💬 Interactive mode → You'll be asked if needed

### ⚡ Skip Tool Checks (Optional)

Want to set up without checking if AI tools are installed?

```bash
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai claude --ignore-agent-tools
```

> **Use this when:** You're setting up on a different machine or want to configure tools later.

---

## ✅ Verify Installation

After setup, check that everything works:

### 1. Check Agent Skills

Confirm the skills folder was created for your chosen agent:

```bash
ls .claude/skills/          # Claude Code
ls .github/skills/          # GitHub Copilot
ls .gemini/skills/          # Gemini CLI
ls .cursor/skills/          # Cursor
```

**Core skills installed:**

| Skill | Purpose |
| ------- | ---------- |
| `gen-project-ground-rules-setup` | Set project principles |
| `gen-requirement-development` | Create feature specifications |
| `gen-technical-detailed-design` | Generate implementation plans |
| `gen-coding-plan` | Break down into actionable tasks |
| `gen-code-implementation` | Execute the plan |

### 2. Check Subagents

Confirm platform-specific subagents were installed:

```bash
ls .claude/agents/          # Claude Code
ls .github/agents/          # GitHub Copilot
ls .gemini/agents/          # Gemini CLI
```

- ✅ `business-analyst.md` (or `business-analyst.agent.md` for Copilot) should be present

---

## 🛠️ Troubleshooting

### Git Authentication Issues on Linux

Having trouble with Git authentication? Install Git Credential Manager:

```bash
#!/usr/bin/env bash
set -e

echo "⬇️ Downloading Git Credential Manager v2.6.1..."
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb

echo "📦 Installing..."
sudo dpkg -i gcm-linux_amd64.2.6.1.deb

echo "⚙️ Configuring Git..."
git config --global credential.helper manager

echo "🧹 Cleaning up..."
rm gcm-linux_amd64.2.6.1.deb

echo "✅ Done! Git Credential Manager is ready."
```

### Need More Help?

- 📖 Check the [Quick Start Guide](quickstart.md) for next steps
- 🐛 [Report an issue](https://github.com/dauquangthanh/danang-nightlife/issues/new) if something's not working
- 💬 [Ask questions](https://github.com/dauquangthanh/danang-nightlife/discussions) in our community
