<#
.SYNOPSIS
    Check prerequisites for the coding-standards skill.
.DESCRIPTION
    Detects required files (ground-rules.md, architecture.md, standards.md)
    and counts spec files in the repository.
.PARAMETER Json
    Output results as JSON.
.EXAMPLE
    .\scripts\check-prerequisites.ps1
.EXAMPLE
    .\scripts\check-prerequisites.ps1 -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [switch]$Json
)

function Find-RepoRoot {
    $dir = Get-Location
    for ($i = 0; $i -lt 16; $i++) {
        if ((Test-Path "$dir/.git") -or (Test-Path "$dir/pyproject.toml") -or (Test-Path "$dir/README.md")) {
            return $dir.Path
        }
        $parent = Split-Path $dir -Parent
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return (Get-Location).Path
}

function Find-FileInsensitive {
    param([string]$Directory, [string]$FileName)
    if (-not (Test-Path $Directory)) { return $null }
    $found = Get-ChildItem -Path $Directory -Filter $FileName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }
    return $null
}

$RepoRoot = Find-RepoRoot
$DocsDir = Join-Path $RepoRoot "docs"

$GroundRules = Find-FileInsensitive -Directory $DocsDir -FileName "ground-rules.md"
$Architecture = Find-FileInsensitive -Directory $DocsDir -FileName "architecture.md"
$Standards = Find-FileInsensitive -Directory $DocsDir -FileName "standards.md"

$SpecsCount = 0
$SpecsDir = Join-Path $RepoRoot "specs"
if (Test-Path $SpecsDir) {
    $SpecsCount = @(Get-ChildItem -Path $SpecsDir -Filter "spec.md" -Recurse -ErrorAction SilentlyContinue).Count
}

function Get-RelPath {
    param([string]$FullPath)
    if (-not $FullPath) { return $null }
    return $FullPath.Replace("$RepoRoot/", "").Replace("$RepoRoot\", "")
}

if ($Json) {
    $result = @{
        repo_root = $RepoRoot
        found     = @{
            ground_rules = Get-RelPath $GroundRules
            architecture = Get-RelPath $Architecture
            standards    = Get-RelPath $Standards
        }
        status    = @{
            ground_rules_present = [bool]$GroundRules
            architecture_present = [bool]$Architecture
            standards_present    = [bool]$Standards
            specs_count          = $SpecsCount
        }
    }
    $result | ConvertTo-Json -Depth 3
    exit 0
}

Write-Host "Repository root: $RepoRoot"
Write-Host "Checks:"
Write-Host " - docs/ground-rules.md: $(if ($GroundRules) { $GroundRules } else { 'MISSING' })"
Write-Host " - docs/architecture.md: $(if ($Architecture) { $Architecture } else { 'MISSING' })"
Write-Host " - docs/standards.md: $(if ($Standards) { $Standards } else { 'MISSING' })"
Write-Host " - specs/*/spec.md count: $SpecsCount"

if (-not $GroundRules) {
    Write-Host ""
    Write-Error "ground-rules.md is required. Create docs/ground-rules.md and re-run."
    exit 2
}

exit 0
