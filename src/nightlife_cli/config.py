"""Configuration constants and agent definitions for Nightlife CLI."""

from pathlib import Path

# Agent configuration aligned with AI-Agents-Configs.md (25 platforms, April 2026).
# Fields:
#   agent_folder    — where Nightlife skill command files are installed
#   skills_folder   — where agent skills are installed
#   subagents_folder — where custom subagent definition files are installed
#   install_url     — CLI install page (None for IDE-based agents)
#   requires_cli    — True if the agent requires a CLI tool to be present
AGENT_CONFIG = {
    "amp": {
        "name": "Amp",
        "agent_folder": ".amp/commands/",
        "skills_folder": ".amp/skills/",
        "subagents_folder": ".amp/agents/",
        "install_url": "https://ampcode.com/manual#install",
        "requires_cli": True,
    },
    "antigravity": {
        "name": "Google Antigravity",
        "agent_folder": ".agent/rules/",
        "skills_folder": ".agent/skills/",
        "subagents_folder": ".agent/workflows/",
        "install_url": None,
        "requires_cli": False,
    },
    "auggie": {
        "name": "Augment Code",
        "agent_folder": ".augment/rules/",
        "skills_folder": ".augment/skills/",
        "subagents_folder": ".augment/agents/",
        "install_url": "https://docs.augmentcode.com/cli/setup-auggie/install-auggie-cli",
        "requires_cli": True,
    },
    "bob": {
        "name": "IBM Bob",
        "agent_folder": ".bob/commands/",
        "skills_folder": ".bob/skills/",
        "subagents_folder": ".bob/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "claude": {
        "name": "Claude Code",
        "agent_folder": ".claude/commands/",
        "skills_folder": ".claude/skills/",
        "subagents_folder": ".claude/agents/",
        "install_url": "https://docs.anthropic.com/en/docs/claude-code/setup",
        "requires_cli": True,
    },
    "cline": {
        "name": "Cline",
        "agent_folder": ".cline/commands/",
        "skills_folder": ".cline/skills/",
        "subagents_folder": ".cline/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "codebuddy": {
        "name": "CodeBuddy",
        "agent_folder": ".codebuddy/commands/",
        "skills_folder": ".codebuddy/skills/",
        "subagents_folder": ".codebuddy/agents/",
        "install_url": "https://www.codebuddy.ai/cli",
        "requires_cli": True,
    },
    "codex": {
        "name": "Codex CLI",
        "agent_folder": ".codex/commands/",
        "skills_folder": ".codex/skills/",
        "subagents_folder": ".codex/agents/",
        "install_url": "https://github.com/openai/codex",
        "requires_cli": True,
    },
    "copilot": {
        "name": "GitHub Copilot",
        "agent_folder": ".github/agents/",
        "skills_folder": ".github/skills/",
        "subagents_folder": ".github/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "copilot-cli": {
        "name": "GitHub Copilot CLI",
        "agent_folder": ".copilot/agents/",
        "skills_folder": ".copilot/skills/",
        "subagents_folder": ".copilot/agents/",
        "install_url": None,
        "requires_cli": True,
    },
    "cursor-agent": {
        "name": "Cursor",
        "agent_folder": ".cursor/commands/",
        "skills_folder": ".cursor/skills/",
        "subagents_folder": ".cursor/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "forge": {
        "name": "Forge",
        "agent_folder": ".forge/commands/",
        "skills_folder": ".forge/skills/",
        "subagents_folder": ".forge/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "gemini": {
        "name": "Gemini CLI",
        "agent_folder": ".gemini/commands/",
        "skills_folder": ".gemini/skills/",
        "subagents_folder": ".gemini/agents/",
        "install_url": "https://github.com/google-gemini/gemini-cli",
        "requires_cli": True,
    },
    "junie": {
        "name": "Junie",
        "agent_folder": ".junie/commands/",
        "skills_folder": ".junie/skills/",
        "subagents_folder": ".junie/agents/",
        "install_url": None,  # IDE-based (JetBrains)
        "requires_cli": False,
    },
    "kilocode": {
        "name": "Kilo Code",
        "agent_folder": ".kilocode/rules/",
        "skills_folder": ".kilocode/skills/",
        "subagents_folder": ".kilocode/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "kiro": {
        "name": "Kiro",
        "agent_folder": ".kiro/commands/",
        "skills_folder": ".kiro/skills/",
        "subagents_folder": ".kiro/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "opencode": {
        "name": "Open Code",
        "agent_folder": ".opencode/commands/",
        "skills_folder": ".opencode/skills/",
        "subagents_folder": ".opencode/agents/",
        "install_url": "https://opencode.ai",
        "requires_cli": True,
    },
    "pi": {
        "name": "Pi Agent",
        "agent_folder": ".omp/commands/",
        "skills_folder": ".omp/skills/",
        "subagents_folder": ".omp/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "qoder": {
        "name": "Qoder CLI",
        "agent_folder": ".qoder/commands/",
        "skills_folder": ".qoder/skills/",
        "subagents_folder": ".qoder/agents/",
        "install_url": "https://qoder.ai",
        "requires_cli": True,
    },
    "qwen": {
        "name": "Qwen Code",
        "agent_folder": ".qwen/commands/",
        "skills_folder": ".qwen/skills/",
        "subagents_folder": ".qwen/agents/",
        "install_url": "https://github.com/QwenLM/qwen-code",
        "requires_cli": True,
    },
    "roo": {
        "name": "Roo Code",
        "agent_folder": ".roo/rules/",
        "skills_folder": ".roo/skills/",
        "subagents_folder": ".roo/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "tabnine": {
        "name": "Tabnine",
        "agent_folder": ".tabnine/commands/",
        "skills_folder": ".tabnine/skills/",
        "subagents_folder": ".tabnine/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "trae": {
        "name": "Trae",
        "agent_folder": ".trae/commands/",
        "skills_folder": ".trae/skills/",
        "subagents_folder": ".trae/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "vibe": {
        "name": "Mistral Vibe",
        "agent_folder": ".vibe/commands/",
        "skills_folder": ".vibe/skills/",
        "subagents_folder": ".vibe/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "windsurf": {
        "name": "Windsurf",
        "agent_folder": ".windsurf/workflows/",
        "skills_folder": ".windsurf/skills/",
        "subagents_folder": ".windsurf/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
}

SCRIPT_TYPE_CHOICES = {"py": "Python"}

CLAUDE_LOCAL_PATH = Path.home() / ".claude" / "local" / "claude"

# File extension for each agent's command/skill files.
# Only GitHub Copilot (IDE and CLI) use .agent.md; Gemini and Qwen use .toml;
# all others use .md.
EXTENSION_MAP = {
    "amp": ".md",
    "antigravity": ".md",
    "auggie": ".md",
    "bob": ".md",
    "claude": ".md",
    "cline": ".md",
    "codebuddy": ".md",
    "codex": ".md",
    "copilot": ".agent.md",
    "copilot-cli": ".agent.md",
    "cursor-agent": ".md",
    "forge": ".md",
    "gemini": ".toml",
    "junie": ".md",
    "kilocode": ".md",
    "kiro": ".md",
    "opencode": ".md",
    "pi": ".md",
    "qoder": ".md",
    "qwen": ".toml",
    "roo": ".md",
    "tabnine": ".md",
    "trae": ".md",
    "vibe": ".md",
    "windsurf": ".md",
}

# Args placeholder format for each agent.
# Gemini and Qwen use {{args}}; all others use $ARGUMENTS.
ARGS_FORMAT_MAP = {
    "amp": "$ARGUMENTS",
    "antigravity": "$ARGUMENTS",
    "auggie": "$ARGUMENTS",
    "bob": "$ARGUMENTS",
    "claude": "$ARGUMENTS",
    "cline": "$ARGUMENTS",
    "codebuddy": "$ARGUMENTS",
    "codex": "$ARGUMENTS",
    "copilot": "$ARGUMENTS",
    "copilot-cli": "$ARGUMENTS",
    "cursor-agent": "$ARGUMENTS",
    "forge": "$ARGUMENTS",
    "gemini": "{{args}}",
    "junie": "$ARGUMENTS",
    "kilocode": "$ARGUMENTS",
    "kiro": "$ARGUMENTS",
    "opencode": "$ARGUMENTS",
    "pi": "$ARGUMENTS",
    "qoder": "$ARGUMENTS",
    "qwen": "{{args}}",
    "roo": "$ARGUMENTS",
    "tabnine": "$ARGUMENTS",
    "trae": "$ARGUMENTS",
    "vibe": "$ARGUMENTS",
    "windsurf": "$ARGUMENTS",
}

BANNER = """
███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗    ██╗     ██╗███████╗███████╗
████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝    ██║     ██║██╔════╝██╔════╝
██╔██╗ ██║██║██║  ███╗███████║   ██║       ██║     ██║█████╗  █████╗
██║╚██╗██║██║██║   ██║██╔══██║   ██║       ██║     ██║██╔══╝  ██╔══╝
██║ ╚████║██║╚██████╔╝██║  ██║   ██║       ███████╗██║██║     ███████╗
╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚══════╝╚═╝╚═╝     ╚══════╝
"""

TAGLINE = "Da Nang Nightlife - Drive Quality Together with Reusable AI Components"

# GitHub repository information
GITHUB_REPO_OWNER = "dauquangthanh"
GITHUB_REPO_NAME = "danang-nightlife"
