<#
.SYNOPSIS
    Detect required artifacts for project consistency analysis.
.DESCRIPTION
    Checks a feature directory for required (spec.md, design.md, tasks.md) and
    optional (ground-rules.md, architecture.md, standards.md) artifacts.
.PARAMETER FeatureDirectory
    Feature directory to check (default: current directory).
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\check-analysis-prerequisites.ps1 -Json
.EXAMPLE
    .\scripts\check-analysis-prerequisites.ps1 -FeatureDirectory /path/to/feature -Json
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

# Resolve path
try {
    $FeatureDir = (Resolve-Path -Path $FeatureDirectory -ErrorAction Stop).Path
} catch {
    if ($Json) {
        Write-Output "{`"success`":false,`"error`":`"Directory not found: $FeatureDirectory`"}"
    } else {
        Write-Error "Directory not found: $FeatureDirectory"
    }
    exit 1
}

function Find-FileCI {
    param([string]$Dir, [string]$Pattern)
    if (Test-Path $Dir -PathType Container) {
        $found = Get-ChildItem -Path $Dir -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ieq $Pattern } |
            Select-Object -First 1
        if ($found) { return $found.FullName }
    }
    return ''
}

# Required artifacts
$SpecFile = Find-FileCI -Dir $FeatureDir -Pattern 'spec.md'
$DesignFile = Find-FileCI -Dir $FeatureDir -Pattern 'design.md'
$TasksFile = Find-FileCI -Dir $FeatureDir -Pattern 'tasks.md'

# Optional artifacts
$ParentDir = Split-Path -Parent $FeatureDir
$GroundRules = ''
$Architecture = ''
$Standards = ''

$searchDirs = @(
    (Join-Path $FeatureDir 'docs'),
    (Join-Path $ParentDir 'docs'),
    (Join-Path $FeatureDir 'memory'),
    (Join-Path $ParentDir 'memory')
)

foreach ($d in $searchDirs) {
    if (-not $GroundRules) { $GroundRules = Find-FileCI -Dir $d -Pattern 'ground-rules.md' }
}

$docDirs = @(
    (Join-Path $FeatureDir 'docs'),
    (Join-Path $ParentDir 'docs')
)

foreach ($d in $docDirs) {
    if (-not $Architecture) { $Architecture = Find-FileCI -Dir $d -Pattern 'architecture.md' }
    if (-not $Standards) { $Standards = Find-FileCI -Dir $d -Pattern 'standards.md' }
}

# Check required
$MissingRequired = @()
if (-not $SpecFile) { $MissingRequired += 'spec.md' }
if (-not $DesignFile) { $MissingRequired += 'design.md' }
if (-not $TasksFile) { $MissingRequired += 'tasks.md' }

$Success = $MissingRequired.Count -eq 0
$Message = if ($Success) { 'All required artifacts found' } else { "Missing required artifacts: $($MissingRequired -join ', ')" }

$RequiredFound = 3 - $MissingRequired.Count
$OptionalFound = @($GroundRules, $Architecture, $Standards | Where-Object { $_ }).Count
$TotalFound = $RequiredFound + $OptionalFound

# Output
if ($Json) {
    $result = @{
        success               = $Success
        message               = $Message
        feature_dir           = $FeatureDir
        spec_file             = $SpecFile
        design_file           = $DesignFile
        tasks_file            = $TasksFile
        ground_rules_available = [bool]$GroundRules
        architecture_available = [bool]$Architecture
        standards_available    = [bool]$Standards
        total_found           = $TotalFound
        required_found        = $RequiredFound
        optional_found        = $OptionalFound
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host ''
    Write-Host 'Project Consistency Analysis - Prerequisite Check'
    Write-Host '=================================================='
    Write-Host ''
    Write-Host "Feature Directory: $FeatureDir"
    Write-Host ''
    if ($Success) {
        Write-Host 'Status: ✓ SUCCESS' -ForegroundColor Green
    } else {
        Write-Host 'Status: ✗ INCOMPLETE' -ForegroundColor Red
    }
    Write-Host "Message: $Message"
    Write-Host ''
    Write-Host 'Required Artifacts:'
    if ($SpecFile) { Write-Host "  spec.md    : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  spec.md    : ✗ MISSING" -ForegroundColor Red }
    if ($DesignFile) { Write-Host "  design.md  : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  design.md  : ✗ MISSING" -ForegroundColor Red }
    if ($TasksFile) { Write-Host "  tasks.md   : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  tasks.md   : ✗ MISSING" -ForegroundColor Red }
    Write-Host ''
    Write-Host 'Optional Artifacts:'
    if ($GroundRules) { Write-Host "  ground-rules.md : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  ground-rules.md : - NOT FOUND" -ForegroundColor DarkGray }
    if ($Architecture) { Write-Host "  architecture.md : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  architecture.md : - NOT FOUND" -ForegroundColor DarkGray }
    if ($Standards) { Write-Host "  standards.md    : ✓ FOUND" -ForegroundColor Green } else { Write-Host "  standards.md    : - NOT FOUND" -ForegroundColor DarkGray }
    Write-Host ''
    Write-Host "Summary: $TotalFound found ($RequiredFound/3 required, $OptionalFound/3 optional)"
    Write-Host ''

    if (-not $Success) { exit 1 }
}
