<#
.SYNOPSIS
    Set up design directory structure and templates.
.DESCRIPTION
    Creates design workspace for a feature branch, copies templates for
    design documents, research, data models, and API contracts.
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\setup-design.ps1
.EXAMPLE
    .\scripts\setup-design.ps1 -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
    Requirements: git
#>

[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir
$TemplatesDir = Join-Path $SkillDir 'templates'

function Write-Info { param([string]$Msg) if (-not $Json) { Write-Host "i $Msg" } }
function Write-Ok   { param([string]$Msg) if (-not $Json) { Write-Host "✓ $Msg" -ForegroundColor Green } }
function Write-Err  { param([string]$Msg) Write-Host "✗ $Msg" -ForegroundColor Red }

# Check git
try { & git --version 2>$null | Out-Null } catch { Write-Err 'git is not installed'; exit 1 }
$gitCheck = & git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Err 'Git repository required for technical design workflow'
    Write-Err 'Please initialize git and create a feature branch (format: N-feature-name)'
    exit 1
}

# Get current branch
$CurrentBranch = (& git rev-parse --abbrev-ref HEAD).Trim()

# Validate feature branch format
if ($CurrentBranch -notmatch '^\d+-(.+)$') {
    Write-Err 'Not on a feature branch. Technical design requires format: N-feature-name'
    Write-Err 'Please create and checkout a feature branch first'
    exit 1
}

Write-Info "Detected feature branch: $CurrentBranch"

$FeatureDir = "specs/$CurrentBranch"
$FeatureSpec = "$FeatureDir/spec.md"

if (-not (Test-Path $FeatureDir -PathType Container)) {
    Write-Err "Feature directory not found: $FeatureDir"
    Write-Err "Please ensure specs/$CurrentBranch directory exists"
    exit 1
}

Write-Info "Using feature-specific design directory: $FeatureDir"

$FeatureDesign = "$FeatureDir/design.md"
$ResearchDir = "$FeatureDir/research"
$ResearchFile = "$ResearchDir/research.md"
$DataModelFile = "$FeatureDir/data-model.md"
$QuickstartFile = "$FeatureDir/quickstart.md"
$ContractsDir = "$FeatureDir/contracts"

# Create directories
Write-Info 'Creating design directory structure'
New-Item -Path $ResearchDir -ItemType Directory -Force | Out-Null
New-Item -Path $ContractsDir -ItemType Directory -Force | Out-Null
Write-Ok 'Directories created'

# Copy templates
$designTpl = Join-Path $TemplatesDir 'design-template.md'
if (Test-Path $designTpl -PathType Leaf) {
    Write-Info 'Copying design template'
    Copy-Item -Path $designTpl -Destination $FeatureDesign -Force
    Write-Ok "Design template copied to $FeatureDesign"
} else {
    Write-Err "Design template not found at $designTpl"
    exit 1
}

$researchTpl = Join-Path $TemplatesDir 'research-template.md'
if (Test-Path $researchTpl -PathType Leaf) {
    Write-Info 'Copying research template'
    Copy-Item -Path $researchTpl -Destination $ResearchFile -Force
    Write-Ok "Research template copied to $ResearchFile"
}

$dataTpl = Join-Path $TemplatesDir 'data-model-template.md'
if (Test-Path $dataTpl -PathType Leaf) {
    Write-Info 'Copying data model template'
    Copy-Item -Path $dataTpl -Destination $DataModelFile -Force
    Write-Ok "Data model template copied to $DataModelFile"
}

$contractTpl = Join-Path $TemplatesDir 'api-contract-template.md'
if (Test-Path $contractTpl -PathType Leaf) {
    Write-Info 'Copying API contract template'
    Copy-Item -Path $contractTpl -Destination (Join-Path $ContractsDir 'example-contract.md') -Force
    Write-Ok "API contract template copied to $ContractsDir/"
}

# Output
if ($Json) {
    $result = @{
        success        = $true
        has_git        = $true
        current_branch = $CurrentBranch
        feature_spec   = $FeatureSpec
        feature_design = $FeatureDesign
        research_file  = $ResearchFile
        data_model_file = $DataModelFile
        quickstart_file = $QuickstartFile
        contracts_dir  = $ContractsDir
        design_dir     = $FeatureDir
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host ''
    Write-Ok 'Design workspace created successfully!'
    Write-Host ''
    Write-Host "Design directory: $FeatureDir"
    Write-Host "Design document: $FeatureDesign"
    Write-Host "Research document: $ResearchFile"
    Write-Host "Data model: $DataModelFile"
    Write-Host "Contracts directory: $ContractsDir"
    Write-Host "Feature spec: $FeatureSpec"
    Write-Host ''
    Write-Info 'Next steps:'
    Write-Host "  1. Review and fill in $FeatureDesign"
    Write-Host "  2. Conduct research and document in $ResearchFile"
    Write-Host "  3. Design data models in $DataModelFile"
    Write-Host "  4. Create API contracts in $ContractsDir/"
}
