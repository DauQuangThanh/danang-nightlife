<#
.SYNOPSIS
    Check implementation prerequisites for a feature directory.
.DESCRIPTION
    Locates required (tasks.md, design.md) and optional documents,
    checks checklists, and reports readiness for implementation.
.PARAMETER FeatureDirectory
    Feature directory to check (default: current directory).
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\check-implementation.ps1 -Json
.EXAMPLE
    .\scripts\check-implementation.ps1 -FeatureDirectory /path/to/feature -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$FeatureDirectory = '.',

    [switch]$Json
)

$ErrorActionPreference = 'Stop'

try {
    $FeatureDir = (Resolve-Path -Path $FeatureDirectory -ErrorAction Stop).Path
} catch {
    if ($Json) { Write-Output "{`"error`":`"Directory not found: $FeatureDirectory`"}" }
    else { Write-Error "Directory not found: $FeatureDirectory" }
    exit 1
}

$Available = @()
$MissingRequired = @()
$TasksFile = ''
$ChecklistStatus = 'no_checklists'
$ChecklistCount = 0

# Required
foreach ($doc in @('tasks.md', 'design.md')) {
    $p = Join-Path $FeatureDir $doc
    if (Test-Path $p -PathType Leaf) {
        $Available += $doc
        if ($doc -eq 'tasks.md') { $TasksFile = $p }
    } else { $MissingRequired += $doc }
}

# Optional
foreach ($doc in @('spec.md', 'data-model.md', 'research.md')) {
    if (Test-Path (Join-Path $FeatureDir $doc) -PathType Leaf) { $Available += $doc }
}

# Product-level docs
$RepoRoot = $FeatureDir
while ($RepoRoot -ne [System.IO.Path]::GetPathRoot($RepoRoot)) {
    if (Test-Path (Join-Path $RepoRoot '.git') -PathType Container) { break }
    $RepoRoot = Split-Path $RepoRoot -Parent
}
if (Test-Path (Join-Path $RepoRoot 'docs/architecture.md') -PathType Leaf) { $Available += 'docs/architecture.md' }
if (Test-Path (Join-Path $RepoRoot 'docs/standards.md') -PathType Leaf) { $Available += 'docs/standards.md' }
if (Test-Path (Join-Path $RepoRoot 'docs/ground-rules.md') -PathType Leaf) { $Available += 'docs/ground-rules.md' }

# Directories
if (Test-Path (Join-Path $FeatureDir 'contracts') -PathType Container) { $Available += 'contracts/' }

# Checklists
$checklistDir = Join-Path $FeatureDir 'checklists'
if (Test-Path $checklistDir -PathType Container) {
    $ChecklistCount = (Get-ChildItem -Path $checklistDir -File -ErrorAction SilentlyContinue).Count
    if ($ChecklistCount -gt 0) { $ChecklistStatus = 'found' }
}

# Task count
$TaskCount = 0
if ($TasksFile -and (Test-Path $TasksFile -PathType Leaf)) {
    $TaskCount = (Select-String -Path $TasksFile -Pattern '^\- \[ \]' -ErrorAction SilentlyContinue).Count
}

$Success = $MissingRequired.Count -eq 0

if ($Json) {
    $result = @{
        success          = $Success
        feature_dir      = $FeatureDir
        tasks_file       = $TasksFile
        available_docs   = $Available
        missing_required = $MissingRequired
        task_count       = $TaskCount
        checklist_status = $ChecklistStatus
        checklist_count  = $ChecklistCount
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host "Implementation Check: $FeatureDir"
    Write-Host '========================================='
    Write-Host ''
    if ($Success) { Write-Host '✓ All required documents found' -ForegroundColor Green }
    else { Write-Host "✗ Missing required: $($MissingRequired -join ', ')" -ForegroundColor Red }
    Write-Host ''
    Write-Host "Available ($($Available.Count)):"
    foreach ($doc in $Available) { Write-Host "  - $doc" }
    Write-Host ''
    Write-Host "Tasks: $TaskCount"
    Write-Host "Checklists: $ChecklistStatus ($ChecklistCount files)"

    if (-not $Success) { exit 1 }
}
