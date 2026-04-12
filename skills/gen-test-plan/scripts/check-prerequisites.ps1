# check-prerequisites.ps1 - Check prerequisites for test plan generation
#
# Usage:
#   .\scripts\check-prerequisites.ps1 [-Json] [-FeatureDir /path/to/feature]
#
# Parameters:
#   -Json          Output results as JSON
#   -FeatureDir    Specify feature directory explicitly

param(
    [switch]$Json,
    [string]$FeatureDir = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir

function Test-FeatureDir($Path) {
    return (Test-Path (Join-Path $Path "spec.md"))
}

function Find-FeatureDir {
    $cwd = Get-Location

    # Check current directory
    if (Test-FeatureDir $cwd) { return $cwd.Path }

    # Check specs/* subdirectories
    foreach ($searchDir in @("$cwd/specs", "$cwd/phoenix/specs", "$cwd/docs/specs")) {
        if (Test-Path $searchDir -PathType Container) {
            Get-ChildItem -Path $searchDir -Directory | ForEach-Object {
                if (Test-FeatureDir $_.FullName) { return $_.FullName }
            }
        }
    }

    return $null
}

# Find feature directory
if ($FeatureDir) {
    if (-not (Test-Path $FeatureDir -PathType Container)) {
        if ($Json) {
            Write-Output "{`"success`":false,`"error`":`"Directory not found: $FeatureDir`"}"
        } else {
            Write-Error "Directory not found: $FeatureDir"
        }
        exit 1
    }
    $FeatureDir = (Resolve-Path $FeatureDir).Path
} else {
    $FeatureDir = Find-FeatureDir
    if (-not $FeatureDir) {
        if ($Json) {
            Write-Output "{`"success`":false,`"error`":`"No feature directory found`",`"message`":`"Could not find directory containing spec.md`"}"
        } else {
            Write-Error "No feature directory found"
            Write-Host "Could not find directory containing spec.md"
        }
        exit 1
    }
}

# Scan documents
$Available = @()
$MissingRequired = @()

# Required: spec.md
$SpecFile = $null
if (Test-Path (Join-Path $FeatureDir "spec.md")) {
    $Available += "spec.md"
    $SpecFile = Join-Path $FeatureDir "spec.md"
} else {
    $MissingRequired += "spec.md"
}

# Recommended: design.md
$DesignFile = $null
if (Test-Path (Join-Path $FeatureDir "design.md")) {
    $Available += "design.md"
    $DesignFile = Join-Path $FeatureDir "design.md"
}

# Optional documents
foreach ($doc in @("data-model.md", "research.md", "quickstart.md", "tasks.md")) {
    if (Test-Path (Join-Path $FeatureDir $doc)) {
        $Available += $doc
    }
}

$contractsDir = Join-Path $FeatureDir "contracts"
if (Test-Path $contractsDir -PathType Container) {
    $count = (Get-ChildItem -Path $contractsDir -Filter "*.md" -File).Count
    if ($count -gt 0) { $Available += "contracts/ ($count files)" }
}

# Check product-level docs
$RepoRoot = $FeatureDir
while ($RepoRoot -ne [System.IO.Path]::GetPathRoot($RepoRoot)) {
    if (Test-Path (Join-Path $RepoRoot ".git")) { break }
    $RepoRoot = Split-Path -Parent $RepoRoot
}
if (Test-Path (Join-Path $RepoRoot "docs/ground-rules.md")) { $Available += "docs/ground-rules.md" }
if (Test-Path (Join-Path $RepoRoot "docs/architecture.md")) { $Available += "docs/architecture.md" }
if (Test-Path (Join-Path $RepoRoot "docs/standards.md")) { $Available += "docs/standards.md" }

# Copy templates if not present
$TestPlanFile = Join-Path $FeatureDir "test-plan.md"
$E2ETestPlanFile = Join-Path $FeatureDir "e2e-test-plan.md"

$templateTP = Join-Path $SkillDir "templates/test-plan-template.md"
$templateE2E = Join-Path $SkillDir "templates/e2e-test-plan-template.md"

if (-not (Test-Path $TestPlanFile) -and (Test-Path $templateTP)) {
    Copy-Item $templateTP $TestPlanFile
    if (-not $Json) { Write-Host "✓ Copied test-plan template to $TestPlanFile" }
}

if (-not (Test-Path $E2ETestPlanFile) -and (Test-Path $templateE2E)) {
    Copy-Item $templateE2E $E2ETestPlanFile
    if (-not $Json) { Write-Host "✓ Copied e2e-test-plan template to $E2ETestPlanFile" }
}

# Output
if ($Json) {
    $availJson = ($Available | ForEach-Object { "`"$_`"" }) -join ","
    $missingJson = ($MissingRequired | ForEach-Object { "`"$_`"" }) -join ","
    $specJson = if ($SpecFile) { "`"$SpecFile`"" } else { "null" }
    $designJson = if ($DesignFile) { "`"$DesignFile`"" } else { "null" }
    $warning = if ($MissingRequired.Count -gt 0) { ",`"warning`":`"Missing required: $($MissingRequired -join ', ')`"" } else { "" }

    Write-Output "{`"success`":true,`"feature_dir`":`"$FeatureDir`",`"spec_file`":$specJson,`"design_file`":$designJson,`"test_plan_file`":`"$TestPlanFile`",`"e2e_test_plan_file`":`"$E2ETestPlanFile`",`"available_docs`":[$availJson],`"missing_required`":[$missingJson]$warning}"
} else {
    Write-Host "✓ Feature directory: $FeatureDir"
    Write-Host ""
    Write-Host "✓ Available documents ($($Available.Count)):"
    foreach ($doc in $Available) { Write-Host "  - $doc" }

    Write-Host ""
    Write-Host "✓ Output files:"
    Write-Host "  - Test Plan: $TestPlanFile"
    Write-Host "  - E2E Test Plan: $E2ETestPlanFile"

    if ($MissingRequired.Count -gt 0) {
        Write-Host ""
        Write-Warning "Missing required documents:"
        foreach ($doc in $MissingRequired) { Write-Host "  - $doc" }
        exit 1
    }
}
