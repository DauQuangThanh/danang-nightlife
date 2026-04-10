"""Template operations for Nightlife CLI."""

import json
import re
import shutil
import tempfile
import zipfile
from pathlib import Path
from typing import TYPE_CHECKING

import httpx

from .config import AGENT_CONFIG, ARGS_FORMAT_MAP, EXTENSION_MAP
from .github import download_template_from_github
from .ui import console

if TYPE_CHECKING:
    from .ui import StepTracker


def _process_command_content(content: str, ai_assistant: str, agent_folder: str, cmd_name: str = "", script_type: str = "py") -> str:
    """Process a command file's content: extract script commands from frontmatter,
    replace {SCRIPT}/{AGENT_SCRIPT} placeholders, strip script sections from
    frontmatter, and rewrite scripts/ paths to [agent_folder]/[cmd_name]/scripts/.

    This mirrors what create-release-packages.sh's generate_commands() does
    for release builds, ensuring local template installs produce identical output.
    """
    # Normalize line endings
    content = content.replace('\r\n', '\n').replace('\r', '\n')

    # Scripts live inside the per-command subfolder: [agent_folder]/[cmd_name]/scripts/
    scripts_dest = f"{agent_folder}/{cmd_name}/scripts/" if cmd_name else f"{agent_folder}/scripts/"

    def _rewrite_script_paths(text: str) -> str:
        text = text.replace('scripts/', scripts_dest)
        # Prevent double-prefixing if content was already processed
        text = text.replace(f"{agent_folder}/{scripts_dest}", scripts_dest)
        return text

    # Check if file has YAML frontmatter
    if not content.startswith('---\n'):
        # No frontmatter; just rewrite paths
        return _rewrite_script_paths(content)

    # Split into frontmatter and body
    parts = content.split('---\n', 2)
    if len(parts) < 3:
        return _rewrite_script_paths(content)

    frontmatter = parts[1]
    body = parts[2]

    # Extract script command from frontmatter (e.g., "scripts:\n   py: python scripts/check-prerequisites.py ...")
    script_command = ''
    script_match = re.search(
        r'^scripts:\s*\n\s+' + re.escape(script_type) + r':\s*(.+)$',
        frontmatter, re.MULTILINE
    )
    if script_match:
        script_command = script_match.group(1).strip()

    # Extract agent_script command from frontmatter
    agent_script_command = ''
    agent_script_match = re.search(
        r'^agent_scripts:\s*\n\s+' + re.escape(script_type) + r':\s*(.+)$',
        frontmatter, re.MULTILINE
    )
    if agent_script_match:
        agent_script_command = agent_script_match.group(1).strip()

    # Replace {SCRIPT} placeholder in body with the extracted script command
    if script_command:
        body = body.replace('{SCRIPT}', script_command)

    # Replace {AGENT_SCRIPT} placeholder in body with the extracted agent script command
    if agent_script_command:
        body = body.replace('{AGENT_SCRIPT}', agent_script_command)

    # Remove scripts: and agent_scripts: sections from frontmatter
    # Each section is: key line + indented child lines
    cleaned_lines = []
    skip_section = False
    for line in frontmatter.splitlines():
        if re.match(r'^scripts:\s*$', line) or re.match(r'^agent_scripts:\s*$', line):
            skip_section = True
            continue
        if skip_section:
            # If line is indented, it's part of the section to skip
            if line.startswith(' ') or line.startswith('\t') or line == '':
                continue
            else:
                # New top-level key, stop skipping
                skip_section = False
        cleaned_lines.append(line)

    cleaned_frontmatter = '\n'.join(cleaned_lines)
    if cleaned_frontmatter and not cleaned_frontmatter.endswith('\n'):
        cleaned_frontmatter += '\n'

    # Reassemble with frontmatter
    result = '---\n' + cleaned_frontmatter + '---\n' + body

    # Rewrite scripts/ paths to [agent_folder]/scripts/ (avoid double-prefixing)
    result = _rewrite_script_paths(result)

    return result


def handle_vscode_settings(sub_item, dest_file, rel_path, verbose=False, tracker=None) -> None:
    """Handle merging or copying of .vscode/settings.json files."""
    def log(message, color="green"):
        if verbose and not tracker:
            console.print(f"[{color}]{message}[/] {rel_path}")

    try:
        with open(sub_item, 'r', encoding='utf-8') as f:
            new_settings = json.load(f)

        if dest_file.exists():
            merged = merge_json_files(dest_file, new_settings, verbose=verbose and not tracker)
            with open(dest_file, 'w', encoding='utf-8') as f:
                json.dump(merged, f, indent=4)
                f.write('\n')
            log("Merged:", "green")
        else:
            shutil.copy2(sub_item, dest_file)
            log("Copied (no existing settings.json):", "blue")

    except Exception as e:
        log(f"Warning: Could not merge, copying instead: {e}", "yellow")
        shutil.copy2(sub_item, dest_file)


def merge_json_files(existing_path: Path, new_content: dict, verbose: bool = False) -> dict:
    """Merge new JSON content into existing JSON file.

    Performs a deep merge where:
    - New keys are added
    - Existing keys are preserved unless overwritten by new content
    - Nested dictionaries are merged recursively
    - Lists and other values are replaced (not merged)

    Args:
        existing_path: Path to existing JSON file
        new_content: New JSON content to merge in
        verbose: Whether to print merge details

    Returns:
        Merged JSON content as dict
    """
    try:
        with open(existing_path, 'r', encoding='utf-8') as f:
            existing_content = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        # If file doesn't exist or is invalid, just use new content
        return new_content

    def deep_merge(base: dict, update: dict) -> dict:
        """Recursively merge update dict into base dict."""
        result = base.copy()
        for key, value in update.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                # Recursively merge nested dictionaries
                result[key] = deep_merge(result[key], value)
            else:
                # Add new key or replace existing value
                result[key] = value
        return result

    merged = deep_merge(existing_content, new_content)

    if verbose:
        console.print(f"[cyan]Merged JSON file:[/cyan] {existing_path.name}")

    return merged


def copy_local_template(
    project_path: Path,
    source_path: Path,
    ai_assistant: str,
    script_type: str = "py",
    is_current_dir: bool = False,
    verbose: bool = True,
    tracker: "StepTracker | None" = None,
    is_first_agent: bool = True
) -> Path:
    """Copy local template files to the project directory.

    Each agent is self-contained: command files, templates, scripts, and shared
    assets all land inside the agent-specific folder. No .nightlife/ folder is
    created or required.

    Args:
        is_first_agent: Kept for API compatibility but no longer affects behaviour
                        since every agent folder is independently self-contained.
    """

    # Source directories
    agents_src_dir = source_path / "agents"
    skills_dir = source_path / "skills"

    if verbose and not tracker:
        console.print(f"[cyan]Copying templates from:[/cyan] {source_path}")

    # Create project directory if needed
    if not is_current_dir:
        project_path.mkdir(parents=True, exist_ok=True)

    # Determine target structure based on AI assistant
    agent_config = AGENT_CONFIG.get(ai_assistant)
    if not agent_config:
        raise ValueError(f"Unknown AI assistant: {ai_assistant}")

    agent_folder = agent_config["agent_folder"]
    skills_folder = agent_config["skills_folder"]
    subagents_folder = agent_config.get("subagents_folder")

    # Ensure agent root directory exists
    agent_path = project_path / agent_folder
    agent_path.mkdir(parents=True, exist_ok=True)

    # Install subagents from agents/ directory into the platform's subagents folder.
    # GitHub Copilot (IDE and CLI) uses .agent.md; all other platforms use .md.
    if agents_src_dir.exists() and subagents_folder:
        subagents_path = project_path / subagents_folder
        subagents_path.mkdir(parents=True, exist_ok=True)
        subagent_ext = ".agent.md" if ai_assistant in ("copilot", "copilot-cli") else ".md"
        for agent_file in sorted(agents_src_dir.iterdir()):
            if agent_file.is_file() and agent_file.suffix == ".md":
                dest_file = subagents_path / f"{agent_file.stem}{subagent_ext}"
                shutil.copy2(agent_file, dest_file)
                if verbose and not tracker:
                    console.print(f"[green]✓[/green] Installed subagent {dest_file.name} → {subagents_folder}")

    # Copy skills to agent-specific skills folder.
    # Use dirs_exist_ok=True to merge when multiple agents share the same skills_folder.
    if skills_dir.exists():
        skills_path = project_path / skills_folder
        skills_path.mkdir(parents=True, exist_ok=True)
        for skill_item in skills_dir.iterdir():
            if skill_item.is_dir():
                shutil.copytree(skill_item, skills_path / skill_item.name, dirs_exist_ok=True)
        if verbose and not tracker:
            console.print(f"[green]✓[/green] Created {ai_assistant} skills in {skills_folder}")

    # Create CLAUDE.md and AGENTS.md in the project root if they don't exist
    agent_file_template = source_path / "templates" / "agent-file-template.md"
    if agent_file_template.exists():
        template_content = agent_file_template.read_text()
        for agent_doc_file in ["CLAUDE.md", "AGENTS.md"]:
            doc_path = project_path / agent_doc_file
            if not doc_path.exists():
                doc_path.write_text(template_content)
                if verbose and not tracker:
                    console.print(f"[green]✓[/green] Created {agent_doc_file}")

    if tracker:
        tracker.complete(f"copy-{ai_assistant}", "templates copied")

    return project_path


def download_and_extract_template(
    project_path: Path,
    ai_assistant: str,
    script_type: str = "py",
    is_current_dir: bool = False,
    *,
    verbose: bool = True,
    tracker: "StepTracker | None" = None,
    client: httpx.Client = None,
    debug: bool = False,
    github_token: str = None,
    local_templates: bool = False,
    template_path: str = None,
    is_first_agent: bool = True
) -> Path:
    """Download the latest release and extract it to create a new project.
    Returns project_path. Uses tracker if provided (with keys: fetch, download, extract, cleanup)
    If local_templates is True, copies from local template_path instead of downloading.

    Args:
        is_first_agent: If True, copies shared .nightlife folder. If False, skips it to avoid redundancy.
    """
    current_dir = Path.cwd()

    # Handle local templates
    if local_templates:
        if tracker:
            tracker.start(f"copy-{ai_assistant}")

        # Determine template source path
        if template_path:
            source_path = Path(template_path).resolve()
        else:
            # Default to repo root (assume we're in src/nightlife_cli)
            source_path = Path(__file__).parent.parent.parent.resolve()

        if not source_path.exists():
            error_msg = f"Template path does not exist: {source_path}"
            if tracker:
                tracker.error(f"copy-{ai_assistant}", error_msg)
            raise FileNotFoundError(error_msg)

        if verbose and not tracker:
            console.print(f"[cyan]Using local templates from:[/cyan] {source_path}")

        # Build the template by creating a structure similar to the release package
        return copy_local_template(project_path, source_path, ai_assistant, script_type, is_current_dir, verbose, tracker, is_first_agent)

    # Original GitHub download logic
    if tracker:
        tracker.start(f"fetch-{ai_assistant}", "contacting GitHub API")
    try:
        zip_path, meta = download_template_from_github(
            ai_assistant,
            current_dir,
            script_type=script_type,
            verbose=verbose and tracker is None,
            show_progress=(tracker is None),
            client=client,
            debug=debug,
            github_token=github_token
        )
        if tracker:
            tracker.complete(f"fetch-{ai_assistant}", f"release {meta['release']} ({meta['size']:,} bytes)")
            tracker.add(f"download-{ai_assistant}", "Download template")
            tracker.complete(f"download-{ai_assistant}", meta['filename'])
    except Exception as e:
        if tracker:
            tracker.error(f"fetch-{ai_assistant}", str(e))
        else:
            if verbose:
                console.print(f"[red]Error downloading template:[/red] {e}")
        raise

    if tracker:
        tracker.add(f"extract-{ai_assistant}", "Extract template")
        tracker.start(f"extract-{ai_assistant}")
    elif verbose:
        console.print("Extracting template...")

    try:
        if not is_current_dir:
            project_path.mkdir(parents=True, exist_ok=True)

        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_contents = zip_ref.namelist()
            if tracker:
                tracker.start("zip-list")
                tracker.complete("zip-list", f"{len(zip_contents)} entries")
            elif verbose:
                console.print(f"[cyan]ZIP contains {len(zip_contents)} items[/cyan]")

            # Extract to temp directory, then use copy_local_template to build
            # agent-specific folder structure (same logic as --local-templates)
            with tempfile.TemporaryDirectory() as temp_dir:
                temp_path = Path(temp_dir)
                zip_ref.extractall(temp_path)

                extracted_items = list(temp_path.iterdir())
                if tracker:
                    tracker.start("extracted-summary")
                    tracker.complete("extracted-summary", f"temp {len(extracted_items)} items")
                elif verbose:
                    console.print(f"[cyan]Extracted {len(extracted_items)} items to temp location[/cyan]")

                # Handle nested directory structure
                source_dir = temp_path
                if len(extracted_items) == 1 and extracted_items[0].is_dir() and not extracted_items[0].name.startswith('.'):
                    source_dir = extracted_items[0]

                # Use copy_local_template to build the agent-specific layout
                # from the extracted skills/ and agent-commands/ directories
                copy_local_template(
                    project_path, source_dir, ai_assistant, script_type,
                    is_current_dir, verbose, tracker, is_first_agent
                )

    except Exception as e:
        if tracker:
            tracker.error(f"extract-{ai_assistant}", str(e))
        else:
            if verbose:
                console.print(f"[red]Error extracting template:[/red] {e}")
                if debug:
                    from rich.panel import Panel
                    console.print(Panel(str(e), title="Extraction Error", border_style="red"))

        if not is_current_dir and project_path.exists():
            shutil.rmtree(project_path)
        raise
    else:
        if tracker:
            tracker.complete(f"extract-{ai_assistant}")
    finally:
        if tracker:
            tracker.add("cleanup", "Remove temporary archive")

        if zip_path.exists():
            zip_path.unlink()
            if tracker:
                tracker.complete("cleanup")
            elif verbose:
                console.print(f"Cleaned up: {zip_path.name}")

    return project_path
