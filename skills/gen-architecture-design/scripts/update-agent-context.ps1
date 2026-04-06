<#
.SYNOPSIS
    Update agent context files with architecture reference.
.DESCRIPTION
    Adds a reference to docs/architecture.md in agent configuration files.
.PARAMETER AgentType
    Specific agent type to update (optional). Updates all if omitted.
.EXAMPLE
    .\scripts\update-agent-context.ps1
.EXAMPLE
    .\scripts\update-agent-context.ps1 -AgentType copilot
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$AgentType
)

$ErrorActionPreference = 'Stop'

function Find-RepoRoot {
    $current = (Get-Location).Path
    while ($current -ne [System.IO.Path]::GetPathRoot($current)) {
        if (Test-Path (Join-Path $current '.git') -PathType Container) {
            return $current
        }
        $current = Split-Path -Parent $current
    }
    return (Get-Location).Path
}

$RootDir = Find-RepoRoot
$ArchDoc = Join-Path $RootDir 'docs' 'architecture.md'
$ArchRef = "`n`n# Architecture Context`nPlease refer to [System Architecture](docs/architecture.md) for architectural decisions and patterns.`n"

if (-not (Test-Path $ArchDoc -PathType Leaf)) {
    Write-Warning "Architecture document not found at $ArchDoc"
    exit 0
}

function Get-AgentFile {
    param([string]$Agent)
    switch ($Agent) {
        'copilot'      { return Join-Path $RootDir '.github' 'copilot-instructions.md' }
        'cursor-agent' { return Join-Path $RootDir '.cursorrules' }
        'windsurf'     { return Join-Path $RootDir '.windsurfrules' }
        default        { return '' }
    }
}

function Update-AgentFile {
    param([string]$Agent, [string]$File)
    if (-not (Test-Path $File -PathType Leaf)) { return }
    $content = Get-Content -Path $File -Raw -Encoding UTF8
    if ($content -match 'docs/architecture\.md') {
        Write-Host "INFO: $Agent already references architecture documentation." -ForegroundColor Green
        return
    }
    Write-Host "INFO: Updating $Agent..." -ForegroundColor Green
    Add-Content -Path $File -Value $ArchRef -Encoding UTF8
    Write-Host "INFO: Added architecture reference to $Agent" -ForegroundColor Green
}

$Agents = @('copilot', 'cursor-agent', 'windsurf')
$updated = 0

if ($AgentType) {
    $file = Get-AgentFile -Agent $AgentType
    if ($file -and (Test-Path $file -PathType Leaf)) {
        Update-AgentFile -Agent $AgentType -File $file
        $updated++
    }
} else {
    foreach ($agent in $Agents) {
        $file = Get-AgentFile -Agent $agent
        if ($file -and (Test-Path $file -PathType Leaf)) {
            Update-AgentFile -Agent $agent -File $file
            $updated++
        }
    }
}

if ($updated -eq 0) {
    Write-Host 'INFO: No agent context files required updates.' -ForegroundColor Green
} else {
    Write-Host "INFO: Updated $updated agent context file(s)." -ForegroundColor Green
}
