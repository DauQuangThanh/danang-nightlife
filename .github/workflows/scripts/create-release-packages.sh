#!/usr/bin/env bash
set -euo pipefail

# create-release-packages.sh (workflow-local)
# Build Danang Nightlife template release archives for each supported AI assistant.
# Usage: .github/workflows/scripts/create-release-packages.sh <version>
#   Version argument should include leading 'v'.
#   Optionally set AGENTS env var to limit what gets built.
#     AGENTS: space or comma separated subset of: claude gemini copilot cursor-agent qwen opencode windsurf codex kilocode auggie roo codebuddy amp shai q bob jules qoder antigravity (default: all)
#   Examples:
#     AGENTS=claude $0 v0.2.0
#     AGENTS="copilot,gemini" $0 v0.2.0

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version-with-v-prefix>" >&2
  exit 1
fi
NEW_VERSION="$1"
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must look like v0.0.0" >&2
  exit 1
fi

echo "Building release packages for $NEW_VERSION"

# Create and use .genreleases directory for all build artifacts
GENRELEASES_DIR=".genreleases"
mkdir -p "$GENRELEASES_DIR"
rm -rf "$GENRELEASES_DIR"/* || true

rewrite_paths() {
  # Rewrite bare scripts/ references to [agent_folder]/[cmd_name]/scripts/ so paths
  # are relative to the project root and self-contained within each command folder.
  local agent_folder="$1"
  local cmd_name="$2"
  sed -E \
    -e "s@(/?)scripts/@${agent_folder}/${cmd_name}/scripts/@g"
}

generate_commands() {
  local agent=$1 ext=$2 arg_format=$3 output_dir=$4 script_variant=$5 agent_folder=$6
  mkdir -p "$output_dir"
  for cmd_dir in agent-commands/*/; do
    [[ -d "$cmd_dir" ]] || continue
    local name description script_command agent_script_command body
    name=$(basename "$cmd_dir")

    # Skip shared-templates — handled separately in build_variant
    [[ "$name" == "shared-templates" ]] && continue

    local template="$cmd_dir/$name.md"
    [[ -f "$template" ]] || continue

    # Normalize line endings
    file_content=$(tr -d '\r' < "$template")

    # Extract description and script command from YAML frontmatter
    description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
    script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"':[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, ""); print; exit}')

    if [[ -z $script_command ]]; then
      echo "Warning: no script command found for $script_variant in $template" >&2
      script_command="(Missing script command for $script_variant)"
    fi

    # Extract agent_script command from YAML frontmatter if present
    agent_script_command=$(printf '%s\n' "$file_content" | awk '
      /^agent_scripts:$/ { in_agent_scripts=1; next }
      in_agent_scripts && /^[[:space:]]*'"$script_variant"':[[:space:]]*/ {
        sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, "")
        print
        exit
      }
      in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
    ')

    # Replace {SCRIPT} placeholder with the script command
    body=$(printf '%s\n' "$file_content" | sed "s|{SCRIPT}|${script_command}|g")

    # Replace {AGENT_SCRIPT} placeholder with the agent script command if found
    if [[ -n $agent_script_command ]]; then
      body=$(printf '%s\n' "$body" | sed "s|{AGENT_SCRIPT}|${agent_script_command}|g")
    fi

    # Remove the scripts: and agent_scripts: sections from frontmatter while preserving YAML structure
    body=$(printf '%s\n' "$body" | awk '
      /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
      in_frontmatter && /^scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^agent_scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^[a-zA-Z].*:/ && skip_scripts { skip_scripts=0 }
      in_frontmatter && skip_scripts && /^[[:space:]]/ { next }
      { print }
    ')

    # Apply other substitutions and rewrite scripts/ paths
    body=$(printf '%s\n' "$body" | sed "s/{ARGS}/$arg_format/g" | sed "s/__AGENT__/$agent/g" | rewrite_paths "$agent_folder" "$name")

    case $ext in
      toml)
        body=$(printf '%s\n' "$body" | sed 's/\\/\\\\/g')
        { echo "description = \"$description\""; echo; echo "prompt = \"\"\""; echo "$body"; echo "\"\"\""; } > "$output_dir/nightlife.$name.$ext" ;;
      md)
        echo "$body" > "$output_dir/nightlife.$name.$ext" ;;
      agent.md)
        echo "$body" > "$output_dir/nightlife.$name.$ext" ;;
    esac

    # Copy per-command template files AND subdirectories (e.g. scripts/) alongside
    # the command file so agent files can reference them with relative paths.
    local has_cmd_content=false
    for item in "$cmd_dir"*; do
      [[ -e "$item" ]] || continue
      [[ "$(basename "$item")" == "$name.md" ]] && continue
      has_cmd_content=true
      break
    done
    if $has_cmd_content; then
      mkdir -p "$output_dir/$name"
      for item in "$cmd_dir"*; do
        [[ -e "$item" ]] || continue
        [[ "$(basename "$item")" == "$name.md" ]] && continue
        if [[ -f "$item" ]]; then
          cp "$item" "$output_dir/$name/"
        elif [[ -d "$item" ]]; then
          cp -r "$item" "$output_dir/$name/"
        fi
      done
    fi
  done

  # Copy shared-templates assets (e.g. agent-file-template.md) into the agent folder
  if [[ -d "agent-commands/shared-templates" ]]; then
    mkdir -p "$output_dir/shared-templates"
    for f in agent-commands/shared-templates/*; do
      [[ -f "$f" ]] || continue
      [[ "$(basename "$f")" == "vscode-settings.json" ]] && continue
      cp "$f" "$output_dir/shared-templates/"
    done
  fi
}

generate_skills() {
  local agent=$1 output_dir=$2
  [[ -d skills ]] || return 0
  mkdir -p "$output_dir"
  
  # Copy all skill subdirectories
  for skill_dir in skills/*; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$output_dir/$skill_name"
  done
  
  echo "Copied skills -> $output_dir"
}

build_variant() {
  local agent=$1
  local base_dir="$GENRELEASES_DIR/sdd-${agent}-package"
  echo "Building $agent package..."
  mkdir -p "$base_dir"

  # NOTE: No .nightlife/ folder is created. Each agent package is self-contained:
  # command files, per-command templates, shared assets, and scripts all live
  # inside the agent-specific folder.
  #
  # NOTE: We substitute {ARGS} internally. Outward tokens differ intentionally:
  #   * Markdown/prompt (claude, copilot, cursor-agent, opencode, ...): $ARGUMENTS
  #   * TOML (gemini, qwen): {{args}}
  # This keeps formats readable without extra abstraction.

  case $agent in
    claude)
      mkdir -p "$base_dir/.claude/commands"
      generate_commands claude md "\$ARGUMENTS" "$base_dir/.claude/commands" "py" ".claude/commands"
      generate_skills claude "$base_dir/.claude/skills" ;;
    gemini)
      mkdir -p "$base_dir/.gemini/commands"
      generate_commands gemini toml "{{args}}" "$base_dir/.gemini/commands" "py" ".gemini/commands"
      generate_skills gemini "$base_dir/.gemini/extensions"
      [[ -f agent_templates/gemini/GEMINI.md ]] && cp agent_templates/gemini/GEMINI.md "$base_dir/GEMINI.md" ;;
    copilot)
      mkdir -p "$base_dir/.github/agents"
      mkdir -p "$base_dir/.github/prompts"
      generate_commands copilot agent.md "\$ARGUMENTS" "$base_dir/.github/agents" "py" ".github/agents"
      # Also generate prompts for slash commands (reuses same agent_folder for script rewriting)
      for cmd_dir in agent-commands/*/; do
         [[ -d "$cmd_dir" ]] || continue
         local name file_content description script_command agent_script_command body
         name=$(basename "$cmd_dir")
         [[ "$name" == "shared-templates" ]] && continue
         local template="$cmd_dir/$name.md"
         [[ -f "$template" ]] || continue
         file_content=$(tr -d '\r' < "$template")
         description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
         script_command=$(printf '%s\n' "$file_content" | awk -v sv="py" '/^[[:space:]]*py:[[:space:]]*/ {sub(/^[[:space:]]*py:[[:space:]]*/, ""); print; exit}')
         [[ -z $script_command ]] && script_command="(Missing script command for py)"
         agent_script_command=$(printf '%s\n' "$file_content" | awk '
           /^agent_scripts:$/ { in_agent_scripts=1; next }
           in_agent_scripts && /^[[:space:]]*py:[[:space:]]*/ {
             sub(/^[[:space:]]*py:[[:space:]]*/, "")
             print
             exit
           }
           in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
         ')
         body=$(printf '%s\n' "$file_content" | sed "s|{SCRIPT}|${script_command}|g")
         [[ -n $agent_script_command ]] && body=$(printf '%s\n' "$body" | sed "s|{AGENT_SCRIPT}|${agent_script_command}|g")
         body=$(printf '%s\n' "$body" | awk '
           /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
           in_frontmatter && /^scripts:$/ { skip_scripts=1; next }
           in_frontmatter && /^agent_scripts:$/ { skip_scripts=1; next }
           in_frontmatter && /^[a-zA-Z].*:/ && skip_scripts { skip_scripts=0 }
           in_frontmatter && skip_scripts && /^[[:space:]]/ { next }
           { print }
         ')
         body=$(printf '%s\n' "$body" | sed "s/{ARGS}/\$ARGUMENTS/g" | sed "s/__AGENT__/copilot/g" | rewrite_paths ".github/agents" "$name")
         echo "$body" > "$base_dir/.github/prompts/nightlife.$name.prompt.md"
       done
      generate_skills copilot "$base_dir/.github/skills"
      # Create VS Code workspace settings
      mkdir -p "$base_dir/.vscode"
      [[ -f agent-commands/shared-templates/vscode-settings.json ]] && cp agent-commands/shared-templates/vscode-settings.json "$base_dir/.vscode/settings.json"
      ;;
    cursor-agent)
      mkdir -p "$base_dir/.cursor/commands"
      generate_commands cursor-agent md "\$ARGUMENTS" "$base_dir/.cursor/commands" "py" ".cursor/commands"
      generate_skills cursor-agent "$base_dir/.cursor/rules" ;;
    qwen)
      mkdir -p "$base_dir/.qwen/commands"
      generate_commands qwen toml "{{args}}" "$base_dir/.qwen/commands" "py" ".qwen/commands"
      generate_skills qwen "$base_dir/.qwen/skills"
      [[ -f agent_templates/qwen/QWEN.md ]] && cp agent_templates/qwen/QWEN.md "$base_dir/QWEN.md" ;;
    opencode)
      mkdir -p "$base_dir/.opencode/command"
      generate_commands opencode md "\$ARGUMENTS" "$base_dir/.opencode/command" "py" ".opencode/command"
      generate_skills opencode "$base_dir/.opencode/skill" ;;
    windsurf)
      mkdir -p "$base_dir/.windsurf/workflows"
      generate_commands windsurf md "\$ARGUMENTS" "$base_dir/.windsurf/workflows" "py" ".windsurf/workflows"
      generate_skills windsurf "$base_dir/.windsurf/skills" ;;
    codex)
      mkdir -p "$base_dir/.codex/commands"
      generate_commands codex md "\$ARGUMENTS" "$base_dir/.codex/commands" "py" ".codex/commands"
      generate_skills codex "$base_dir/.codex/skills" ;;
    kilocode)
      mkdir -p "$base_dir/.kilocode/rules"
      generate_commands kilocode md "\$ARGUMENTS" "$base_dir/.kilocode/rules" "py" ".kilocode/rules"
      generate_skills kilocode "$base_dir/.kilocode/skills" ;;
    auggie)
      mkdir -p "$base_dir/.augment/rules"
      generate_commands auggie md "\$ARGUMENTS" "$base_dir/.augment/rules" "py" ".augment/rules"
      generate_skills auggie "$base_dir/.augment/rules" ;;
    roo)
      mkdir -p "$base_dir/.roo/rules"
      generate_commands roo md "\$ARGUMENTS" "$base_dir/.roo/rules" "py" ".roo/rules"
      generate_skills roo "$base_dir/.roo/skills" ;;
    codebuddy)
      mkdir -p "$base_dir/.codebuddy/commands"
      generate_commands codebuddy md "\$ARGUMENTS" "$base_dir/.codebuddy/commands" "py" ".codebuddy/commands"
      generate_skills codebuddy "$base_dir/.codebuddy/skills" ;;
    amp)
      mkdir -p "$base_dir/.agents/commands"
      generate_commands amp md "\$ARGUMENTS" "$base_dir/.agents/commands" "py" ".agents/commands"
      generate_skills amp "$base_dir/.agents/skills" ;;
    shai)
      mkdir -p "$base_dir/.shai/commands"
      generate_commands shai md "\$ARGUMENTS" "$base_dir/.shai/commands" "py" ".shai/commands"
      generate_skills shai "$base_dir/.shai/commands" ;;
    q)
      mkdir -p "$base_dir/.amazonq/prompts"
      generate_commands q md "\$ARGUMENTS" "$base_dir/.amazonq/prompts" "py" ".amazonq/prompts"
      generate_skills q "$base_dir/.amazonq/cli-agents" ;;
    bob)
      mkdir -p "$base_dir/.bob/commands"
      generate_commands bob md "\$ARGUMENTS" "$base_dir/.bob/commands" "py" ".bob/commands"
      generate_skills bob "$base_dir/.bob/skills" ;;
    jules)
      mkdir -p "$base_dir/.agent"
      generate_commands jules md "\$ARGUMENTS" "$base_dir/.agent" "py" ".agent"
      generate_skills jules "$base_dir/skills" ;;
    qoder)
      mkdir -p "$base_dir/.qoder/commands"
      generate_commands qoder md "\$ARGUMENTS" "$base_dir/.qoder/commands" "py" ".qoder/commands"
      generate_skills qoder "$base_dir/.qoder/skills" ;;
    antigravity)
      mkdir -p "$base_dir/.agent/rules"
      generate_commands antigravity md "\$ARGUMENTS" "$base_dir/.agent/rules" "py" ".agent/rules"
      generate_skills antigravity "$base_dir/.agent/skills" ;;
  esac
   ( cd "$base_dir" && zip -r "../nightlife-template-${agent}-${NEW_VERSION}.zip" . )
   echo "Created $GENRELEASES_DIR/nightlife-template-${agent}-${NEW_VERSION}.zip"
}

# Determine agent list
ALL_AGENTS=(claude gemini copilot cursor-agent qwen opencode windsurf codex kilocode auggie roo codebuddy amp shai q bob jules qoder antigravity)

norm_list() {
  # convert comma+space separated -> line separated unique while preserving order of first occurrence
  tr ',\n' '  ' | awk '{for(i=1;i<=NF;i++){if(!seen[$i]++){printf((out?"\n":"") $i);out=1}}}END{printf("\n")}'
}

validate_subset() {
  local type=$1; shift; local -n allowed=$1; shift; local items=("$@")
  local invalid=0
  for it in "${items[@]}"; do
    local found=0
    for a in "${allowed[@]}"; do [[ $it == "$a" ]] && { found=1; break; }; done
    if [[ $found -eq 0 ]]; then
      echo "Error: unknown $type '$it' (allowed: ${allowed[*]})" >&2
      invalid=1
    fi
  done
  return $invalid
}

if [[ -n ${AGENTS:-} ]]; then
   mapfile -t AGENT_LIST < <(printf '%s' "$AGENTS" | norm_list)
   validate_subset agent ALL_AGENTS "${AGENT_LIST[@]}" || exit 1
else
   AGENT_LIST=("${ALL_AGENTS[@]}")
fi

echo "Agents: ${AGENT_LIST[*]}"

for agent in "${AGENT_LIST[@]}"; do
  build_variant "$agent"
done

echo "Archives in $GENRELEASES_DIR:"
ls -1 "$GENRELEASES_DIR"/nightlife-template-*-"${NEW_VERSION}".zip

