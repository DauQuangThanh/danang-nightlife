# 📦 Installation Guide

**Get started with Danang Nightlife in minutes.**

---

## ⚙️ What You Need

Before installing, make sure you have:

| Requirement | Description |
| ------------- | ------------- |
| **Operating System** | Linux, macOS, or Windows (PowerShell supported) |
| **AI Assistant** | [Claude Code](https://www.anthropic.com/claude-code), [GitHub Copilot](https://code.visualstudio.com/), [Gemini CLI](https://github.com/google-gemini/gemini-cli), or [CodeBuddy CLI](https://www.codebuddy.ai/cli) |
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

Specify which AI assistant to use:

```bash
# Claude Code
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai claude

# Gemini CLI
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai gemini

# GitHub Copilot
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai copilot

# CodeBuddy CLI
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <project_name> --ai codebuddy
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

### 1. Check for Slash Commands

Your AI agent should show these core commands:

**Core Workflow:**

| Command | Purpose |
| --------- | ---------- |
| `/nightlife.set-ground-rules` | Set project principles |
| `/nightlife.specify` | Create specifications |
| `/nightlife.design` | Generate implementation plans |
| `/nightlife.taskify` | Break down into actionable tasks |
| `/nightlife.implement` | Execute the plan |

### 2. Check Script Files

Each command's scripts live inside the agent folder, e.g.:

```bash
ls .claude/commands/specify/scripts/    # Claude Code
ls .github/agents/specify/scripts/     # GitHub Copilot
```

- ✅ Python scripts (`.py`) for cross-platform execution, one `scripts/` folder per command

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
