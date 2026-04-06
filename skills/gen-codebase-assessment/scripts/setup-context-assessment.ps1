<#
.SYNOPSIS
    Setup context assessment for brownfield project.
.DESCRIPTION
    Creates assessment environment and copies template.
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\setup-context-assessment.ps1
.EXAMPLE
    .\scripts\setup-context-assessment.ps1 -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir

# Find repository root by searching upward for .git directory
function Find-RepoRoot {
    $current = (Get-Location).Path
    while ($current -ne [System.IO.Path]::GetPathRoot($current)) {
        if (Test-Path -Path (Join-Path $current '.git') -PathType Container) {
            return $current
        }
        $current = Split-Path -Parent $current
    }
    return (Get-Location).Path
}

$RepoRoot = Find-RepoRoot
$DocsDir = Join-Path $RepoRoot 'docs'
$ContextAssessment = Join-Path $DocsDir 'context-assessment.md'
$Template = Join-Path $SkillDir 'templates' 'context-assessment-template.md'

# Ensure docs directory exists
if (-not (Test-Path -Path $DocsDir -PathType Container)) {
    New-Item -Path $DocsDir -ItemType Directory -Force | Out-Null
}

# Copy template
if (Test-Path -Path $Template -PathType Leaf) {
    Copy-Item -Path $Template -Destination $ContextAssessment -Force
    if (-not $Json) {
        Write-Host "✓ Copied context assessment template to $ContextAssessment"
    }
} else {
    if (-not $Json) {
        Write-Warning "Context assessment template not found at $Template"
        Write-Host 'Creating empty assessment file'
    }
    New-Item -Path $ContextAssessment -ItemType File -Force | Out-Null
}

# Check if we're in a git repo
$HasGit = (Test-Path -Path (Join-Path $RepoRoot '.git') -PathType Container).ToString().ToLower()

# Output results
if ($Json) {
    $result = @{
        CONTEXT_ASSESSMENT = $ContextAssessment
        DOCS_DIR           = $DocsDir
        REPO_ROOT          = $RepoRoot
        HAS_GIT            = $HasGit
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host "Repository root: $RepoRoot"
    Write-Host "Documentation directory: $DocsDir"
    Write-Host "Assessment file: $ContextAssessment"
    Write-Host "Git repository: $HasGit"
    Write-Host ''
    Write-Host '✓ Setup complete. Context assessment template is ready at:'
    Write-Host "  $ContextAssessment"
}
