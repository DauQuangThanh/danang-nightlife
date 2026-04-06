<#
.SYNOPSIS
    Generate Skill Script - Generates a new agent skill structure.

.DESCRIPTION
    Generates a new agent skill directory structure following the Agent Skills
    specification, including SKILL.md with frontmatter and sample scripts.

.PARAMETER Name
    Name of the skill (lowercase, hyphens only, 1-64 chars).

.PARAMETER OutputDir
    Directory to create skill in (default: current directory).

.EXAMPLE
    .\generate-skill.ps1 -Name my-new-skill
    .\generate-skill.ps1 -Name pdf-processing -OutputDir ./skills/

.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (Windows/macOS/Linux)
    Author:   ODC-X Platform
    Version:  1.0
    License:  MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,

    [Parameter(Position = 1)]
    [string]$OutputDir = "."
)

# ── Helper functions ────────────────────────────────────────────────
function Write-Success { param([string]$Msg) Write-Host "✓ $Msg" -ForegroundColor Green }
function Write-Err     { param([string]$Msg) Write-Host "✗ $Msg" -ForegroundColor Red }
function Write-Info    { param([string]$Msg) Write-Host "ℹ $Msg" -ForegroundColor Blue }
function Write-Warn    { param([string]$Msg) Write-Host "⚠ $Msg" -ForegroundColor Yellow }

# ── Validate skill name ────────────────────────────────────────────
function Test-SkillName {
    param([string]$SkillName)

    if ([string]::IsNullOrEmpty($SkillName)) {
        Write-Err "Name cannot be empty"
        return $false
    }

    if ($SkillName.Length -gt 64) {
        Write-Err "Name too long (max 64 chars)"
        return $false
    }

    if ($SkillName -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        Write-Err "Name must be lowercase, alphanumeric, hyphens only, no consecutive hyphens, no start/end hyphens"
        return $false
    }

    return $true
}

if (-not (Test-SkillName -SkillName $Name)) {
    Write-Err "Invalid skill name: $Name"
    exit 1
}

# ── Resolve template directory ──────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path (Split-Path -Parent $ScriptDir) "templates"

function Get-TemplateContent {
    param([string]$TemplateName)

    $templatePath = Join-Path $TemplateDir $TemplateName
    if (Test-Path $templatePath) {
        return Get-Content -Path $templatePath -Raw -Encoding UTF8
    }

    # Fallback: current directory/templates
    $fallbackPath = Join-Path "templates" $TemplateName
    if (Test-Path $fallbackPath) {
        return Get-Content -Path $fallbackPath -Raw -Encoding UTF8
    }

    Write-Warn "Template not found: $TemplateName. Using internal default."
    return $null
}

# ── Create skill ────────────────────────────────────────────────────
$RootPath = Join-Path $OutputDir $Name

if (Test-Path $RootPath) {
    Write-Err "Directory already exists: $RootPath"
    exit 1
}

try {
    # 1. Create directory structure
    New-Item -ItemType Directory -Path (Join-Path $RootPath "scripts") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $RootPath "references") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $RootPath "templates") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $RootPath "assets") -Force | Out-Null
    Write-Success "Created directory structure at $RootPath"

    # 2. Create SKILL.md
    $Today = (Get-Date).ToString("yyyy-MM-dd")
    $TitleName = ($Name -split '-' | ForEach-Object {
        $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower()
    }) -join ' '

    $skillTemplate = Get-TemplateContent "skill-template.md"
    if ($skillTemplate) {
        $content = $skillTemplate `
            -replace 'name: skill-name', "name: $Name" `
            -replace '# Skill Name', "# $TitleName" `
            -replace 'last_updated: "YYYY-MM-DD"', "last_updated: `"$Today`""
        $content | Out-File -FilePath (Join-Path $RootPath "SKILL.md") -Encoding UTF8 -NoNewline
        Write-Success "Created SKILL.md from template"
    }
    else {
        $fallbackContent = @"
---
name: $Name
description: "[ACTION 1], [ACTION 2], and [ACTION 3]. Use when [SCENARIO 1], [SCENARIO 2], or when user mentions [KEYWORD 1], [KEYWORD 2], or [KEYWORD 3]."
license: MIT
metadata:
  author: Your Name
  version: "1.0"
  last_updated: "$Today"
---

# $TitleName

## Overview

[Brief 2-3 sentence explanation of what this skill does and its primary purpose]

## When to Use

- [Specific scenario 1]
- [Specific scenario 2]
- [Specific scenario 3]

## Prerequisites

**Required:**
- None

## Instructions

### Step 1: [Action Name]

[Instructions]

## Examples

### Example 1: [Use Case]

**Input:**
``````
[Input]
``````

**Output:**
``````
[Output]
``````
"@
        $fallbackContent | Out-File -FilePath (Join-Path $RootPath "SKILL.md") -Encoding UTF8 -NoNewline
        Write-Info "Created SKILL.md (default content)"
    }

    # 3. Create .gitkeep files
    New-Item -ItemType File -Path (Join-Path $RootPath "references/.gitkeep") -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $RootPath "templates/.gitkeep") -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $RootPath "assets/.gitkeep") -Force | Out-Null

    # 4. Create sample scripts (Bash + PowerShell)
    $bashTemplate = Get-TemplateContent "script-template.sh"
    if ($bashTemplate) {
        $bashContent = $bashTemplate -replace '\[Script Name\]', "$Name-script"
        $bashContent | Out-File -FilePath (Join-Path $RootPath "scripts/$Name.sh") -Encoding UTF8 -NoNewline
        Write-Success "Created Bash script at scripts/$Name.sh"
    }

    $psTemplate = Get-TemplateContent "script-template.ps1"
    if ($psTemplate) {
        $psContent = $psTemplate -replace '\[Script Name\]', "$Name-script"
        $psContent | Out-File -FilePath (Join-Path $RootPath "scripts/$Name.ps1") -Encoding UTF8 -NoNewline
        Write-Success "Created PowerShell script at scripts/$Name.ps1"
    }

    Write-Host ""
    Write-Host "Skill '$Name' created successfully!" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Edit $RootPath/SKILL.md to add description and instructions"
    Write-Host "2. Customize scripts in $RootPath/scripts/ (.sh, .ps1)"
    Write-Host "3. Validate using: .\scripts\validate-skill.ps1 -Path $RootPath"
}
catch {
    Write-Err "Failed to create skill: $_"
    exit 1
}
