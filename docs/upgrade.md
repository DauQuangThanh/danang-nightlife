# Upgrade Guide

> You have Danang Nightlife installed and want to upgrade to the latest version to get new features, bug fixes, or updated slash commands. This guide covers both upgrading the CLI tool and updating your project files.

---

## Quick Reference

| What to Upgrade | Command | When to Use |
| ---------------- | --------- |-------------|
| **CLI Tool Only** | `uv tool install nightlife-cli --force --from git+https://github.com/dauquangthanh/danang-nightlife.git` | Get latest CLI features without touching project files |
| **Project Files** | `nightlife init --here --force --upgrade --ai <your-agent>` | Update slash commands, templates, and scripts in your project (automatic backups) |
| **Both** | Run CLI upgrade, then project update | Recommended for major version updates |

---

## Part 1: Upgrade the CLI Tool

The CLI tool (`nightlife`) is separate from your project files. Upgrade it to get the latest features and bug fixes.

### If you installed with `uv tool install`

```bash
uv tool install nightlife-cli --force --from git+https://github.com/dauquangthanh/danang-nightlife.git
```

### If you use one-shot `uvx` commands

No upgrade needed—`uvx` always fetches the latest version. Just run your commands as normal:

```bash
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init --here --ai copilot
```

### Verify the upgrade

```bash
nightlife check
```

This shows installed tools and confirms the CLI is working.

---

## Part 2: Updating Project Files

When Danang Nightlife releases new features (like new slash commands or updated templates), you need to refresh your project's Danang Nightlife files.

### What gets updated?

Running `nightlife init --here --force --upgrade` will automatically back up and replace:

- ✅ **Agent folders** (e.g., .claude/, .github/, .cursor/) — entire root folders are backed up and replaced (commands, per-command templates, and scripts are all self-contained inside these folders)
- ✅ **Skills folder** (for Jules agent) - backed up if present

**Automatic backups are created with timestamps** (e.g., `.claude.backup.20260204_120000`). User project files (specs/, source code, etc.) are preserved and never touched.

### What stays safe?

These files are **never touched** by the upgrade—the template packages don't even contain them:

- ✅ **Your specifications** (`specs/001-my-feature/spec.md`, etc.) - **CONFIRMED SAFE**
- ✅ **Your implementation plans** (`specs/001-my-feature/plan.md`, `tasks.md`, etc.) - **CONFIRMED SAFE**
- ✅ **Your source code** - **CONFIRMED SAFE**
- ✅ **Your git history** - **CONFIRMED SAFE**

The `specs/` directory is completely excluded from template packages and will never be modified during upgrades.

### Update command

Run this inside your project directory:

```bash
nightlife init --here --force --upgrade --ai <your-agent>
```

Replace `<your-agent>` with your AI assistant. Refer to this list of [Supported AI Agents](../README.md#-supported-ai-agents)

**Example:**

```bash
nightlife init --here --force --upgrade --ai copilot
```

### Understanding the `--upgrade` flag

The `--upgrade` flag enables upgrade mode, which:

- Detects existing Nightlife installation (looks for `nightlife.*` files in known agent folders)
- Automatically backs up agent root folders with timestamps (e.g., `.claude.backup.20260204_120000`)
- Replaces agent folders and skills (for Jules) with latest templates
- Preserves user content (specs/, source code, git history)

---

## ⚠️ Important Warnings

### 1. Automatic backups are created

The upgrade process automatically creates timestamped backups of replaced agent root folders (e.g., `.claude.backup.20260204_120000`, `.github.backup.20260204_120000`). To restore from backup:

```bash
# List backup folders
ls -la | grep backup

# Remove current folder and rename backup (example for Claude)
rm -rf .claude
mv .claude.backup.20260204_120000 .claude
```

### 2. Ground rules file

The `docs/ground-rules.md` file lives in your project root (not inside any agent folder) and is **never touched** by upgrades. Your customizations are always preserved.

### 3. Custom template modifications

Per-command templates (e.g., `spec-template.md`, `design-template.md`) live inside each agent folder (e.g., `.claude/commands/specify/`). The upgrade replaces these along with the agent folder. Restore from the timestamped backup if needed.

### 3. Duplicate slash commands (IDE-based agents)

Some IDE-based agents (like Kilo Code, Windsurf) may show **duplicate slash commands** after upgrading—both old and new versions appear.

**Solution:** Manually delete the old command files from your agent's folder.

**Example for Kilo Code:**

```bash
# Navigate to the agent's commands folder
cd .kilocode/rules/

# List files and identify duplicates
ls -la

# Delete old versions (example filenames - yours may differ)
rm nightlife.specify-old.md
rm nightlife.design-v1.md
```

Restart your IDE to refresh the command list.

---

## Common Scenarios

### Scenario 1: "I just want new slash commands"

```bash
# Upgrade CLI (if using persistent install)
uv tool install nightlife-cli --force --from git+https://github.com/dauquangthanh/danang-nightlife.git

# Update project files to get new commands (automatic backups created)
nightlife init --here --force --upgrade --ai copilot
```

### Scenario 2: "I customized templates"

```bash
# Upgrade CLI
uv tool install nightlife-cli --force --from git+https://github.com/dauquangthanh/danang-nightlife.git

# Update project (automatic backups created, e.g., .github.backup.TIMESTAMP)
nightlife init --here --force --upgrade --ai copilot

# Restore customized templates from backup
cp -r .github.backup.*/agents/specify .github/agents/
# Manually merge template changes if needed
```

### Scenario 3: "I see duplicate slash commands in my IDE"

This happens with IDE-based agents (Kilo Code, Windsurf, Roo Code, etc.).

```bash
# Find the agent folder (example: .kilocode/rules/)
cd .kilocode/rules/

# List all files
ls -la

# Delete old command files
rm nightlife.old-command-name.md

# Restart your IDE
```

### Scenario 4: "I'm working on a project without Git"

If you initialized your project with `--no-git`, you can still upgrade:

```bash
# Run upgrade (automatic backups created, e.g., .claude.backup.TIMESTAMP)
nightlife init --here --force --upgrade --ai copilot --no-git
```

The `--no-git` flag skips git initialization but doesn't affect file updates.

---

## Using `--no-git` Flag

The `--no-git` flag tells Danang Nightlife to **skip git repository initialization**. This is useful when:

- You manage version control differently (Mercurial, SVN, etc.)
- Your project is part of a larger monorepo with existing git setup
- You're experimenting and don't want version control yet

**During initial setup:**

```bash
nightlife init my-project --ai copilot --no-git
```

**During upgrade:**

```bash
nightlife init --here --force --ai copilot --no-git
```

### What `--no-git` does NOT do

❌ Does NOT prevent file updates
❌ Does NOT skip slash command installation
❌ Does NOT affect template merging

It **only** skips running `git init` and creating the initial commit.

### Working without Git

If you use `--no-git`, you'll need to manage feature directories manually:

**Set the `SPECIFY_FEATURE` environment variable** before using planning commands:

```bash
# Bash/Zsh
export SPECIFY_FEATURE="001-my-feature"

# PowerShell
$env:SPECIFY_FEATURE = "001-my-feature"
```

This tells Danang Nightlife which feature directory to use when creating specs, plans, and tasks.

**Why this matters:** Without git, Danang Nightlife can't detect your current branch name to determine the active feature. The environment variable provides that context manually.

---

## Troubleshooting

### "Slash commands not showing up after upgrade"

**Cause:** Agent didn't reload the command files.

**Fix:**

1. **Restart your IDE/editor** completely (not just reload window)
2. **For CLI-based agents**, verify files exist:

   ```bash
   ls -la .claude/commands/      # Claude Code
   ls -la .gemini/commands/       # Gemini
   ls -la .cursor/commands/       # Cursor
   ```

3. **Check agent-specific setup:**
   - Codex requires `CODEX_HOME` environment variable
   - Some agents need workspace restart or cache clearing

### "I lost my ground rules customizations"

`docs/ground-rules.md` lives in your project root and is **never overwritten** by upgrades — it is not part of any agent folder. If the file is missing, restore from git:

```bash
git restore docs/ground-rules.md
```

### "Warning: Current directory is not empty"

**Full warning message:**

```
Warning: Current directory is not empty (25 items)
Template files will be merged with existing content and may overwrite existing files
Do you want to continue? [y/N]
```

**What this means:**

This warning appears when you run `nightlife init --here` (or `nightlife init .`) in a directory that already has files. It's telling you:

1. **The directory has existing content** - In the example, 25 files/folders
2. **Files will be merged** - New template files will be added alongside your existing files
3. **Some files may be overwritten** - If you already have Danang Nightlife files (`.claude/`, `.nightlife/`, etc.), they'll be replaced with the new versions

**What gets overwritten:**

Only Danang Nightlife infrastructure files:

- Agent command files, per-command templates, and scripts inside agent folders (`.claude/commands/`, `.github/agents/`, etc.)
- Skills folder (Jules only)

**What stays untouched:**

- Your `specs/` directory (specifications, plans, tasks)
- Your source code files
- Your `.git/` directory and git history
- Any other files not part of Danang Nightlife templates

**How to respond:**

- **Type `y` and press Enter** - Proceed with the merge (recommended if upgrading)
- **Type `n` and press Enter** - Cancel the operation
- **Use `--force` flag** - Skip this confirmation entirely:

  ```bash
  nightlife init --here --force --ai copilot
  ```

**When you see this warning:**

- ✅ **Expected** when upgrading an existing Nightlife project (use `--upgrade` flag)
- ✅ **Expected** when adding Nightlife to an existing codebase
- ⚠️ **Unexpected** if you thought you were creating a new project in an empty directory

**Prevention tip:** For upgrades, use the `--upgrade` flag to enable automatic backups.

### "CLI upgrade doesn't seem to work"

Verify the installation:

```bash
# Check installed tools
uv tool list

# Should show nightlife-cli

# Verify path
which nightlife

# Should point to the uv tool installation directory
```

If not found, reinstall:

```bash
uv tool uninstall nightlife-cli
uv tool install nightlife-cli --from git+https://github.com/dauquangthanh/danang-nightlife.git
```

### "Do I need to run nightlife every time I open my project?"

**Short answer:** No, you only run `nightlife init` once per project (or when upgrading).

**Explanation:**

The `nightlife` CLI tool is used for:

- **Initial setup:** `nightlife init` to bootstrap Danang Nightlife in your project
- **Upgrades:** `nightlife init --here --force` to update templates and commands
- **Diagnostics:** `nightlife check` to verify tool installation

Once you've run `nightlife init`, the slash commands (like `/nightlife.specify`, `/nightlife.design`, etc.) are **permanently installed** in your project's agent folder (`.claude/`, `.github/prompts/`, etc.). Your AI assistant reads these command files directly—no need to run `nightlife` again.

**If your agent isn't recognizing slash commands:**

1. **Verify command files exist:**

   ```bash
   # For GitHub Copilot
   ls -la .github/prompts/

   # For Claude
   ls -la .claude/commands/
   ```

2. **Restart your IDE/editor completely** (not just reload window)

3. **Check you're in the correct directory** where you ran `nightlife init`

4. **For some agents**, you may need to reload the workspace or clear cache

**Related issue:** If Copilot can't open local files or uses PowerShell commands unexpectedly, this is typically an IDE context issue, not related to `nightlife`. Try:

- Restarting VS Code
- Checking file permissions
- Ensuring the workspace folder is properly opened

---

## Version Compatibility

Danang Nightlife follows semantic versioning for major releases. The CLI and project files are designed to be compatible within the same major version.

**Best practice:** Keep both CLI and project files in sync by upgrading both together during major version changes.

---

## Next Steps

After upgrading:

- **Test new slash commands:** Run `/nightlife.set-ground-rules` or another command to verify everything works
- **Lint Markdown files:** Run `npx markdownlint-cli2 "**/*.md"` before committing
- **Review release notes:** Check [GitHub Releases](https://github.com/dauquangthanh/danang-nightlife/releases) for new features and breaking changes
- **Update workflows:** If new commands were added, update your team's development workflows
- **Check documentation:** Visit [https://dauquangthanh.github.io/danang-nightlife/](https://dauquangthanh.github.io/danang-nightlife/) for updated guides
