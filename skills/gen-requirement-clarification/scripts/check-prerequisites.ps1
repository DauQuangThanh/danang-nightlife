<#
.SYNOPSIS
    Locate feature specification file.
.DESCRIPTION
    Detects git feature branches (format: N-feature-name), locates the
    corresponding specs directory, and returns paths to spec.md and related files.
.PARAMETER Json
    Output results in JSON format.
.PARAMETER PathsOnly
    Only return path information (no validation messages).
.EXAMPLE
    .\scripts\check-prerequisites.ps1 -Json -PathsOnly
.EXAMPLE
    .\scripts\check-prerequisites.ps1
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
    Requirements: git (optional)
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$PathsOnly
)

$ErrorActionPreference = 'Stop'

function Write-Info  { param([string]$Msg) if (-not $PathsOnly -and -not $Json) { Write-Host "i $Msg" } }
function Write-Ok    { param([string]$Msg) if (-not $PathsOnly -and -not $Json) { Write-Host "✓ $Msg" -ForegroundColor Green } }
function Write-Err   { param([string]$Msg) if ($Json) { Write-Error $Msg } else { Write-Host "✗ $Msg" -ForegroundColor Red } }
function Write-Warn  { param([string]$Msg) if (-not $PathsOnly -and -not $Json) { Write-Host "⚠ $Msg" -ForegroundColor Yellow } }

$HasGit = $false
$CurrentBranch = 'main'
$FeatureDir = ''
$FeatureSpec = ''
$FeatureDesign = ''
$Tasks = ''
$SpecExists = $false

# Detect git
try {
    & git --version 2>$null | Out-Null
    $gitCheck = & git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -eq 0) {
        $HasGit = $true
        $branchResult = & git symbolic-ref --short HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            $CurrentBranch = $branchResult.Trim()
        } else {
            $branchResult = & git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0) { $CurrentBranch = $branchResult.Trim() }
        }

        # Check feature branch format: N-feature-name
        if ($CurrentBranch -match '^\d+-(.+)$') {
            $FeatureDir = "specs/$CurrentBranch"
            if (Test-Path $FeatureDir -PathType Container) {
                $FeatureSpec = "$FeatureDir/spec.md"
                $FeatureDesign = "$FeatureDir/design.md"
                $Tasks = "$FeatureDir/tasks.md"
                Write-Info "Detected feature branch: $CurrentBranch"
                Write-Info "Feature directory: $FeatureDir"
            } else {
                Write-Warn "Feature branch detected but directory not found: $FeatureDir"
            }
        } else {
            Write-Warn "Not on a feature branch (expected format: N-feature-name)"
            Write-Warn "Current branch: $CurrentBranch"
        }
    }
} catch {
    Write-Warn 'Not in a git repository or git not available'
}

# Check spec exists
if ($FeatureSpec -and (Test-Path $FeatureSpec -PathType Leaf)) {
    $SpecExists = $true
    Write-Ok "Spec file found: $FeatureSpec"
} else {
    Write-Err 'Spec file not found'
    if ($FeatureSpec) { Write-Info "Expected at: $FeatureSpec" }
    Write-Info 'Please create a spec first using requirements-specification skill'
}

# Output
if ($Json) {
    $result = @{
        has_git        = $HasGit
        current_branch = $CurrentBranch
        feature_dir    = $FeatureDir
        feature_spec   = $FeatureSpec
        feature_design = $FeatureDesign
        tasks          = $Tasks
        spec_exists    = $SpecExists
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host ''
    if ($SpecExists) {
        Write-Ok 'Prerequisites check passed'
    } else {
        Write-Err 'Prerequisites check failed: Spec file not found'
    }
    Write-Host ''
    Write-Host "Git available: $HasGit"
    Write-Host "Current branch: $CurrentBranch"
    Write-Host "Feature directory: $(if ($FeatureDir) { $FeatureDir } else { 'N/A' })"
    Write-Host "Spec file: $(if ($FeatureSpec) { $FeatureSpec } else { 'N/A' })"
    Write-Host "Spec exists: $SpecExists"
    Write-Host ''
    if (-not $SpecExists) {
        Write-Info 'To create a spec, use the requirements-specification skill'
        exit 1
    }
}
