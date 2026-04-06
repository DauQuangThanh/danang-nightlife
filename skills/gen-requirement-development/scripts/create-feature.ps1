<#
.SYNOPSIS
    Create a new feature branch and spec structure.
.DESCRIPTION
    Creates a Git branch with numbered naming convention, generates spec.md
    and checklist.md from templates, and replaces placeholders with feature details.
.PARAMETER Number
    Feature number (required).
.PARAMETER ShortName
    Short name for the feature (required).
.PARAMETER Description
    Feature description (required).
.PARAMETER Json
    Output results as JSON.
.EXAMPLE
    .\scripts\create-feature.ps1 -Number 5 -ShortName "user-auth" -Description "Add user authentication"
.EXAMPLE
    .\scripts\create-feature.ps1 -Json -Number 5 -ShortName "user-auth" -Description "Add user authentication"
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
    Requirements: git
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$Number,

    [Parameter(Mandatory = $true)]
    [string]$ShortName,

    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Description,

    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir
$TemplatesDir = Join-Path $SkillDir 'templates'

# Validate short name
if ($ShortName -notmatch '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$') {
    Write-Error 'Short name must use lowercase letters, numbers, and hyphens only'
    exit 1
}
if ($ShortName -match '--') {
    Write-Error 'Short name cannot contain consecutive hyphens'
    exit 1
}

$FormattedNumber = $Number.ToString('D3')
$BranchName = "$FormattedNumber-$ShortName"
$SpecsDir = "specs/$BranchName"
$SpecFile = "$SpecsDir/spec.md"
$ChecklistDir = "$SpecsDir/checklists"
$ChecklistFile = "$ChecklistDir/requirements.md"

function Write-Info  { param([string]$Msg) if (-not $Json) { Write-Host "i $Msg" } }
function Write-Ok    { param([string]$Msg) if (-not $Json) { Write-Host "✓ $Msg" -ForegroundColor Green } }
function Write-Err   { param([string]$Msg) Write-Host "✗ $Msg" -ForegroundColor Red }
function Write-Warn  { param([string]$Msg) if (-not $Json) { Write-Host "⚠ $Msg" -ForegroundColor Yellow } }

Write-Info "Creating feature: $BranchName"
Write-Info "Description: $Description"

# Check git
try { & git --version 2>$null | Out-Null } catch { Write-Err 'git is not installed'; exit 1 }
$gitCheck = & git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) { Write-Err 'Not in a git repository'; exit 1 }

# Check for existing branches
$localBranches = & git branch 2>$null
if ($localBranches) {
    foreach ($line in $localBranches -split "`n") {
        $b = $line.Trim().TrimStart('* ')
        if ($b -match "^0*$Number-$([regex]::Escape($ShortName))$") {
            Write-Err "Branch with number $Number and short name '$ShortName' already exists: '$b'"
            exit 1
        }
    }
}

$remoteBranches = & git ls-remote --heads origin 2>$null
if ($remoteBranches) {
    foreach ($line in $remoteBranches -split "`n") {
        if ($line -match "refs/heads/(0*$Number-$([regex]::Escape($ShortName)))$") {
            Write-Err "Remote branch already exists: '$($Matches[1])'"
            exit 1
        }
    }
}

if (Test-Path 'specs' -PathType Container) {
    Get-ChildItem -Path 'specs' -Directory | ForEach-Object {
        if ($_.Name -match "^0*$Number-$([regex]::Escape($ShortName))$") {
            Write-Err "Specs directory already exists: '$($_.Name)'"
            exit 1
        }
    }
}

# Create branch
Write-Info "Creating branch: $BranchName"
& git checkout -b $BranchName 2>$null
if ($LASTEXITCODE -ne 0) { Write-Err "Failed to create branch '$BranchName'"; exit 1 }
Write-Ok 'Branch created and checked out'

# Create directories
Write-Info 'Creating directory structure'
New-Item -Path $SpecsDir -ItemType Directory -Force | Out-Null
New-Item -Path $ChecklistDir -ItemType Directory -Force | Out-Null
Write-Ok 'Directories created'

$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

# Copy spec template
$specTemplate = Join-Path $TemplatesDir 'spec-template.md'
if (Test-Path $specTemplate -PathType Leaf) {
    Write-Info 'Copying spec template'
    $content = Get-Content -Path $specTemplate -Raw -Encoding UTF8
    $content = $content -replace '\[Feature Name\]', $ShortName
    $content = $content -replace '\[Number-ShortName\]', $BranchName
    $content = $content -replace '\[Date\]', $CurrentDate
    Set-Content -Path $SpecFile -Value $content -Encoding UTF8 -NoNewline
    Write-Ok 'Spec template created'
} else {
    Write-Warn 'Spec template not found, creating basic spec file'
    $basicSpec = @"
# $ShortName

**Feature ID**: $BranchName
**Status**: Draft
**Created**: $CurrentDate

## Overview

$Description

## User Scenarios & Testing

[To be filled]

## Functional Requirements

[To be filled]

## Success Criteria

[To be filled]

## Assumptions

[To be filled]

## Out of Scope

[To be filled]
"@
    Set-Content -Path $SpecFile -Value $basicSpec -Encoding UTF8 -NoNewline
    Write-Ok 'Basic spec file created'
}

# Copy checklist template
$checklistTemplate = Join-Path $TemplatesDir 'checklist-template.md'
if (Test-Path $checklistTemplate -PathType Leaf) {
    Write-Info 'Copying checklist template'
    $content = Get-Content -Path $checklistTemplate -Raw -Encoding UTF8
    $content = $content -replace '\[FEATURE NAME\]', $ShortName
    $content = $content -replace '\[DATE\]', $CurrentDate
    $content = $content -replace '\[Link to spec\.md\]', '[spec.md](../spec.md)'
    Set-Content -Path $ChecklistFile -Value $content -Encoding UTF8 -NoNewline
    Write-Ok 'Checklist template created'
} else {
    Write-Warn 'Checklist template not found, creating basic checklist'
    $basicChecklist = @"
# Specification Quality Checklist: $ShortName

**Feature**: [spec.md](../spec.md)
**Created**: $CurrentDate

## Content Quality
- [ ] No implementation details
- [ ] Focused on user value
- [ ] All mandatory sections completed

## Requirement Completeness
- [ ] Requirements are testable
- [ ] Success criteria are measurable
- [ ] Edge cases identified

## Feature Readiness
- [ ] Ready for next phase
"@
    Set-Content -Path $ChecklistFile -Value $basicChecklist -Encoding UTF8 -NoNewline
    Write-Ok 'Basic checklist created'
}

# Output
if ($Json) {
    $result = @{
        success        = $true
        branch_name    = $BranchName
        feature_number = $FormattedNumber
        short_name     = $ShortName
        description    = $Description
        spec_file      = $SpecFile
        checklist_file = $ChecklistFile
        specs_dir      = $SpecsDir
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host ''
    Write-Ok 'Feature created successfully!'
    Write-Host ''
    Write-Host "Branch: $BranchName"
    Write-Host "Spec file: $SpecFile"
    Write-Host "Checklist: $ChecklistFile"
    Write-Host ''
    Write-Info 'Next steps:'
    Write-Host "  1. Fill in the specification: $SpecFile"
    Write-Host "  2. Validate using checklist: $ChecklistFile"
    Write-Host "  3. Commit your changes: git add . && git commit -m 'docs: add specification for $ShortName'"
}
