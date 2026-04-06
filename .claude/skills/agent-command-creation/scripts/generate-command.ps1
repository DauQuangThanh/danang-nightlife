<#
.SYNOPSIS
    Generate Command Script - Generates a new agent command file from templates.

.DESCRIPTION
    Generates a new agent command file following the Agent Command Creation Rules.
    Supports 19+ agent platforms with Markdown or TOML formats.

.PARAMETER Name
    Name of the command (lowercase, hyphens, digits only).

.PARAMETER Agent
    Target agent platform (required).

.PARAMETER Project
    Project name for Copilot mode field (default: project).

.EXAMPLE
    .\generate-command.ps1 -Name analyze-code -Agent claude
    .\generate-command.ps1 -Name specify -Agent copilot -Project myapp

.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (Windows/macOS/Linux)
    Author:   Dau Quang Thanh
    Version:  1.0
    License:  MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "claude", "cursor", "windsurf", "kilocode", "roo", "bob", "jules",
        "antigravity", "amazonq", "qoder", "auggie", "codebuddy", "codex",
        "shai", "opencode", "amp", "copilot", "gemini", "qwen"
    )]
    [string]$Agent,

    [Parameter()]
    [string]$Project = "project"
)

# ── Helper functions ────────────────────────────────────────────────
function Write-Success { param([string]$Msg) Write-Host "✓ $Msg" -ForegroundColor Green }
function Write-Err     { param([string]$Msg) Write-Host "✗ $Msg" -ForegroundColor Red }
function Write-Info    { param([string]$Msg) Write-Host "ℹ $Msg" -ForegroundColor Blue }
function Write-Warn    { param([string]$Msg) Write-Host "⚠ $Msg" -ForegroundColor Yellow }

# ── Agent Configuration ────────────────────────────────────────────
# Format: directory, extension, template
$AgentConfig = @{
    "claude"       = @{ Dir = ".claude/commands";     Ext = ".md";        Template = "markdown-command-template.md" }
    "cursor"       = @{ Dir = ".cursor/commands";     Ext = ".md";        Template = "markdown-command-template.md" }
    "windsurf"     = @{ Dir = ".windsurf/workflows";  Ext = ".md";        Template = "markdown-command-template.md" }
    "kilocode"     = @{ Dir = ".kilocode/rules";      Ext = ".md";        Template = "markdown-command-template.md" }
    "roo"          = @{ Dir = ".roo/rules";           Ext = ".md";        Template = "markdown-command-template.md" }
    "bob"          = @{ Dir = ".bob/commands";         Ext = ".md";        Template = "markdown-command-template.md" }
    "jules"        = @{ Dir = ".agent";               Ext = ".md";        Template = "markdown-command-template.md" }
    "antigravity"  = @{ Dir = ".agent/rules";         Ext = ".md";        Template = "markdown-command-template.md" }
    "amazonq"      = @{ Dir = ".amazonq/prompts";     Ext = ".md";        Template = "markdown-command-template.md" }
    "qoder"        = @{ Dir = ".qoder/commands";      Ext = ".md";        Template = "markdown-command-template.md" }
    "auggie"       = @{ Dir = ".augment/rules";       Ext = ".md";        Template = "markdown-command-template.md" }
    "codebuddy"    = @{ Dir = ".codebuddy/commands";  Ext = ".md";        Template = "markdown-command-template.md" }
    "codex"        = @{ Dir = ".codex/commands";      Ext = ".md";        Template = "markdown-command-template.md" }
    "shai"         = @{ Dir = ".shai/commands";        Ext = ".md";        Template = "markdown-command-template.md" }
    "opencode"     = @{ Dir = ".opencode/command";    Ext = ".md";        Template = "markdown-command-template.md" }
    "amp"          = @{ Dir = ".agents/commands";     Ext = ".md";        Template = "markdown-command-template.md" }
    "copilot"      = @{ Dir = ".github/prompts";      Ext = ".prompt.md"; Template = "copilot-command-template.md" }
    "gemini"       = @{ Dir = ".gemini/commands";     Ext = ".toml";      Template = "toml-command-template.toml" }
    "qwen"         = @{ Dir = ".qwen/commands";       Ext = ".toml";      Template = "toml-command-template.toml" }
}

# ── Validate command name ──────────────────────────────────────────
if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    Write-Err "Command name '$Name' must contain only lowercase letters, numbers, and hyphens."
    exit 1
}

# ── Resolve directories ────────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path (Split-Path -Parent $ScriptDir) "templates"

# Project root is 4 levels up from scripts dir
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir)))

function Get-TemplateContent {
    param([string]$TemplateName)

    $templatePath = Join-Path $TemplateDir $TemplateName
    if (Test-Path $templatePath) {
        return Get-Content -Path $templatePath -Raw -Encoding UTF8
    }

    # Fallback: relative to current directory
    $fallbackPath = Join-Path ".github/skills/agent-command-creation/templates" $TemplateName
    if (Test-Path $fallbackPath) {
        return Get-Content -Path $fallbackPath -Raw -Encoding UTF8
    }

    Write-Warn "Template not found: $TemplateName"
    return $null
}

# ── Create command ─────────────────────────────────────────────────
$config = $AgentConfig[$Agent]
$targetDir = Join-Path $ProjectRoot $config.Dir
$targetFile = Join-Path $targetDir "$Name$($config.Ext)"

try {
    # Ensure target directory exists
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Check if file already exists
    if (Test-Path $targetFile) {
        Write-Err "File already exists at $targetFile"
        exit 1
    }

    # Read template and process
    $content = Get-TemplateContent $config.Template
    if (-not $content) {
        Write-Err "Could not load template '$($config.Template)'"
        exit 1
    }

    # Title case the command name
    $titleName = ($Name -split '-' | ForEach-Object {
        $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower()
    }) -join ' '

    # Replace generic header
    $content = $content -replace '# Command Name', "# $titleName"

    # Copilot-specific: replace mode field
    if ($Agent -eq "copilot") {
        $content = $content -replace 'project\.command-name', "$Project.$Name"
    }

    $content | Out-File -FilePath $targetFile -Encoding UTF8 -NoNewline

    Write-Success "Successfully created command: $targetFile"
    Write-Info "Agent: $Agent"
    Write-Info "Format: $($config.Ext)"
}
catch {
    Write-Err "Failed to create command: $_"
    exit 1
}
