<#
.SYNOPSIS
    Check prerequisites and identify feature directory for task generation.
.DESCRIPTION
    Locates the feature directory containing design.md and spec.md,
    scans for required and optional design documents.
.PARAMETER FeatureDir
    Specify feature directory explicitly.
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\check-prerequisites.ps1 -Json
.EXAMPLE
    .\scripts\check-prerequisites.ps1 -FeatureDir /path/to/feature -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [string]$FeatureDir,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

function Test-FeatureDir { param([string]$Dir)
    return (Test-Path (Join-Path $Dir 'design.md') -PathType Leaf) -or (Test-Path (Join-Path $Dir 'spec.md') -PathType Leaf)
}

function Find-FeatureDir {
    $cwd = Get-Location
    if (Test-FeatureDir $cwd) { return $cwd.Path }

    foreach ($searchBase in @('specs', 'phoenix/specs', 'docs/specs')) {
        $searchPath = Join-Path $cwd $searchBase
        if (Test-Path $searchPath -PathType Container) {
            Get-ChildItem -Path $searchPath -Directory | ForEach-Object {
                if (Test-FeatureDir $_.FullName) { return $_.FullName }
            }
        }
    }
    return $null
}

# Find feature directory
if ($FeatureDir) {
    try { $FeatureDir = (Resolve-Path $FeatureDir -ErrorAction Stop).Path }
    catch { Write-Error "Directory not found: $FeatureDir"; exit 1 }
} else {
    $FeatureDir = Find-FeatureDir
    if (-not $FeatureDir) {
        if ($Json) {
            Write-Output '{"success":false,"error":"No feature directory found","message":"Could not find directory containing design.md or spec.md"}'
        } else {
            Write-Error 'No feature directory found'
        }
        exit 1
    }
}

# Scan documents
$Available = @()
$MissingRequired = @()

foreach ($doc in @('design.md', 'spec.md')) {
    if (Test-Path (Join-Path $FeatureDir $doc) -PathType Leaf) { $Available += $doc }
    else { $MissingRequired += $doc }
}

foreach ($doc in @('data-model.md', 'research.md', 'quickstart.md', 'architecture.md')) {
    if (Test-Path (Join-Path $FeatureDir $doc) -PathType Leaf) { $Available += $doc }
}

$contractsDir = Join-Path $FeatureDir 'contracts'
if (Test-Path $contractsDir -PathType Container) {
    $count = (Get-ChildItem -Path $contractsDir -Filter '*.md' -File -ErrorAction SilentlyContinue).Count
    if ($count -gt 0) { $Available += "contracts/ ($count files)" }
}

# Check product-level docs
$RepoRoot = $FeatureDir
while ($RepoRoot -ne [System.IO.Path]::GetPathRoot($RepoRoot)) {
    if (Test-Path (Join-Path $RepoRoot '.git') -PathType Container) { break }
    $RepoRoot = Split-Path $RepoRoot -Parent
}
if (Test-Path (Join-Path $RepoRoot 'docs/architecture.md') -PathType Leaf) { $Available += 'docs/architecture.md' }
if (Test-Path (Join-Path $RepoRoot 'docs/ground-rules.md') -PathType Leaf) { $Available += 'docs/ground-rules.md' }

# Output
if ($Json) {
    $result = @{
        success          = $true
        feature_dir      = $FeatureDir
        available_docs   = $Available
        missing_required = $MissingRequired
    }
    if ($MissingRequired.Count -gt 0) {
        $result['warning'] = "Missing required: $($MissingRequired -join ', ')"
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host "✓ Feature directory: $FeatureDir" -ForegroundColor Green
    Write-Host ''
    Write-Host "✓ Available documents ($($Available.Count)):" -ForegroundColor Green
    foreach ($doc in $Available) { Write-Host "  - $doc" }

    if ($MissingRequired.Count -gt 0) {
        Write-Host ''
        Write-Host "⚠ Missing required documents:" -ForegroundColor Yellow
        foreach ($doc in $MissingRequired) { Write-Host "  - $doc" }
        exit 1
    }
}
