"""Configuration constants and agent definitions for Nightlife CLI."""

from pathlib import Path

# Agent configuration aligned with AI-Agents-Configs.md (25 platforms, April 2026).
# Fields:
#   skills_folder   — where agent skills are installed
#   subagents_folder — where custom subagent definition files are installed
#   install_url     — CLI install page (None for IDE-based agents)
#   requires_cli    — True if the agent requires a CLI tool to be present
AGENT_CONFIG = {
    "amp": {
        "name": "Amp",
        "skills_folder": ".amp/skills/",
        "subagents_folder": ".amp/agents/",
        "install_url": "https://ampcode.com/manual#install",
        "requires_cli": True,
    },
    "antigravity": {
        "name": "Google Antigravity",
        "skills_folder": ".agent/skills/",
        "subagents_folder": ".agent/workflows/",
        "install_url": None,
        "requires_cli": False,
    },
    "auggie": {
        "name": "Augment Code",
        "skills_folder": ".augment/skills/",
        "subagents_folder": ".augment/agents/",
        "install_url": "https://docs.augmentcode.com/cli/setup-auggie/install-auggie-cli",
        "requires_cli": True,
    },
    "bob": {
        "name": "IBM Bob",
        "skills_folder": ".bob/skills/",
        "subagents_folder": ".bob/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "claude": {
        "name": "Claude Code",
        "skills_folder": ".claude/skills/",
        "subagents_folder": ".claude/agents/",
        "install_url": "https://docs.anthropic.com/en/docs/claude-code/setup",
        "requires_cli": True,
    },
    "cline": {
        "name": "Cline",
        "skills_folder": ".cline/skills/",
        "subagents_folder": ".cline/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "codebuddy": {
        "name": "CodeBuddy",
        "skills_folder": ".codebuddy/skills/",
        "subagents_folder": ".codebuddy/agents/",
        "install_url": "https://www.codebuddy.ai/cli",
        "requires_cli": True,
    },
    "codex": {
        "name": "Codex CLI",
        "skills_folder": ".codex/skills/",
        "subagents_folder": ".codex/agents/",
        "install_url": "https://github.com/openai/codex",
        "requires_cli": True,
    },
    "copilot": {
        "name": "GitHub Copilot",
        "skills_folder": ".github/skills/",
        "subagents_folder": ".github/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "copilot-cli": {
        "name": "GitHub Copilot CLI",
        "skills_folder": ".copilot/skills/",
        "subagents_folder": ".copilot/agents/",
        "install_url": None,
        "requires_cli": True,
    },
    "cursor-agent": {
        "name": "Cursor",
        "skills_folder": ".cursor/skills/",
        "subagents_folder": ".cursor/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "forge": {
        "name": "Forge",
        "skills_folder": ".forge/skills/",
        "subagents_folder": ".forge/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "gemini": {
        "name": "Gemini CLI",
        "skills_folder": ".gemini/skills/",
        "subagents_folder": ".gemini/agents/",
        "install_url": "https://github.com/google-gemini/gemini-cli",
        "requires_cli": True,
    },
    "junie": {
        "name": "Junie",
        "skills_folder": ".junie/skills/",
        "subagents_folder": ".junie/agents/",
        "install_url": None,  # IDE-based (JetBrains)
        "requires_cli": False,
    },
    "kilocode": {
        "name": "Kilo Code",
        "skills_folder": ".kilocode/skills/",
        "subagents_folder": ".kilocode/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "kiro": {
        "name": "Kiro",
        "skills_folder": ".kiro/skills/",
        "subagents_folder": ".kiro/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "opencode": {
        "name": "Open Code",
        "skills_folder": ".opencode/skills/",
        "subagents_folder": ".opencode/agents/",
        "install_url": "https://opencode.ai",
        "requires_cli": True,
    },
    "pi": {
        "name": "Pi Agent",
        "skills_folder": ".omp/skills/",
        "subagents_folder": ".omp/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "qoder": {
        "name": "Qoder CLI",
        "skills_folder": ".qoder/skills/",
        "subagents_folder": ".qoder/agents/",
        "install_url": "https://qoder.ai",
        "requires_cli": True,
    },
    "qwen": {
        "name": "Qwen Code",
        "skills_folder": ".qwen/skills/",
        "subagents_folder": ".qwen/agents/",
        "install_url": "https://github.com/QwenLM/qwen-code",
        "requires_cli": True,
    },
    "roo": {
        "name": "Roo Code",
        "skills_folder": ".roo/skills/",
        "subagents_folder": ".roo/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "tabnine": {
        "name": "Tabnine",
        "skills_folder": ".tabnine/skills/",
        "subagents_folder": ".tabnine/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
    "trae": {
        "name": "Trae",
        "skills_folder": ".trae/skills/",
        "subagents_folder": ".trae/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "vibe": {
        "name": "Mistral Vibe",
        "skills_folder": ".vibe/skills/",
        "subagents_folder": ".vibe/agents/",
        "install_url": None,
        "requires_cli": False,
    },
    "windsurf": {
        "name": "Windsurf",
        "skills_folder": ".windsurf/skills/",
        "subagents_folder": ".windsurf/agents/",
        "install_url": None,  # IDE-based
        "requires_cli": False,
    },
}

SCRIPT_TYPE_CHOICES = {"py": "Python"}

CLAUDE_LOCAL_PATH = Path.home() / ".claude" / "local" / "claude"

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
