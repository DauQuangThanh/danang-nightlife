<#
.SYNOPSIS
    Update agent context files with assessment findings.
.DESCRIPTION
    Extracts key findings from the context assessment and updates
    agent-specific configuration files with a summary section.
.PARAMETER AgentType
    Specific agent type to update (optional). Updates all existing agent files if omitted.
.EXAMPLE
    .\scripts\update-agent-context.ps1
.EXAMPLE
    .\scripts\update-agent-context.ps1 -AgentType claude
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
    Supported agents: claude, gemini, copilot, cursor-agent, qwen, opencode, codex,
    windsurf, kilocode, auggie, roo, codebuddy, amp, shai, q, bob, jules, qoder, antigravity
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$AgentType
)

$ErrorActionPreference = 'Stop'

$StartMarker = '<!-- CONTEXT_ASSESSMENT_START -->'
$EndMarker = '<!-- CONTEXT_ASSESSMENT_END -->'

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

# Get agent file path for a given agent type
function Get-AgentFile {
    param([string]$Agent)
    switch ($Agent) {
        'claude'       { return Join-Path $RepoRoot 'CLAUDE.md' }
        'gemini'       { return Join-Path $RepoRoot 'GEMINI.md' }
        'copilot'      { return Join-Path $RepoRoot '.github' 'agents' 'copilot-instructions.md' }
        'cursor-agent' { return Join-Path $RepoRoot '.cursor' 'rules' 'agent-rules.mdc' }
        'qwen'         { return Join-Path $RepoRoot 'QWEN.md' }
        'opencode'     { return Join-Path $RepoRoot 'AGENTS.md' }
        'codex'        { return Join-Path $RepoRoot 'AGENTS.md' }
        'windsurf'     { return Join-Path $RepoRoot '.windsurf' 'rules' 'agent-rules.md' }
        'kilocode'     { return Join-Path $RepoRoot '.kilocode' 'rules' 'agent-rules.md' }
        'auggie'       { return Join-Path $RepoRoot '.augment' 'rules' 'agent-rules.md' }
        'roo'          { return Join-Path $RepoRoot '.roo' 'rules' 'agent-rules.md' }
        'codebuddy'    { return Join-Path $RepoRoot 'CODEBUDDY.md' }
        'amp'          { return Join-Path $RepoRoot 'AGENTS.md' }
        'shai'         { return Join-Path $RepoRoot 'SHAI.md' }
        'q'            { return Join-Path $RepoRoot 'AGENTS.md' }
        'bob'          { return Join-Path $RepoRoot 'AGENTS.md' }
        'jules'        { return Join-Path $RepoRoot 'AGENTS.md' }
        'qoder'        { return Join-Path $RepoRoot 'QODER.md' }
        'antigravity'  { return Join-Path $RepoRoot 'AGENTS.md' }
        default        { return '' }
    }
}

# Extract summary from assessment file
function Get-AssessmentSummary {
    $content = Get-Content -Path $ContextAssessment -Raw -Encoding UTF8
    $lines = $content -split "`n"
    $today = Get-Date -Format 'yyyy-MM-dd'

    # Extract technical health score
    $score = $null
    if ($content -match '\*\*Technical Health Score\*\*: (\d+)/100') {
        $score = $Matches[1]
    }

    # Extract key findings (first 3 bullet points)
    $findings = @()
    $inFindings = $false
    foreach ($line in $lines) {
        if ($line.Trim() -eq '**Key Findings**:') {
            $inFindings = $true
            continue
        }
        if ($inFindings -and $line.Trim().StartsWith('**')) {
            break
        }
        if ($inFindings -and $line.Trim().StartsWith('- ')) {
            $findings += "  $([char]0x2022) $($line.Trim().Substring(2))"
            if ($findings.Count -ge 3) { break }
        }
    }

    $summary = @()
    $summary += '## Context Assessment Summary'
    $summary += ''
    $summary += "**Assessment Date**: $today"
    if ($score) {
        $summary += "**Technical Health Score**: $score/100"
    }
    $summary += ''
    if ($findings.Count -gt 0) {
        $summary += '**Key Findings**:'
        $summary += $findings
    }
    $summary += ''
    $summary += '**Full Assessment**: See `docs/context-assessment.md`'
    $summary += ''

    return ($summary -join "`n")
}

# Update a single agent file
function Update-AgentFile {
    param(
        [string]$AgentKey,
        [string]$AgentFile,
        [string]$Summary
    )

    if (-not (Test-Path -Path $AgentFile -PathType Leaf)) {
        Write-Warning "Agent file not found: $AgentFile (skipping $AgentKey)"
        return
    }

    Write-Host "INFO: Updating $AgentKey context at $AgentFile" -ForegroundColor Green
    $content = Get-Content -Path $AgentFile -Raw -Encoding UTF8

    if ($content.Contains($StartMarker)) {
        # Update existing section
        $pattern = [regex]::Escape($StartMarker) + '[\s\S]*?' + [regex]::Escape($EndMarker)
        $replacement = "$StartMarker`n$Summary`n$EndMarker"
        $content = [regex]::Replace($content, $pattern, $replacement)
    } else {
        # Append new section
        $content = $content.TrimEnd() + "`n`n$StartMarker`n$Summary`n$EndMarker`n"
    }

    Set-Content -Path $AgentFile -Value $content -Encoding UTF8 -NoNewline
    Write-Host "INFO: ✓ Updated context assessment section in $AgentKey" -ForegroundColor Green
}

# Main
$RepoRoot = Find-RepoRoot
$ContextAssessment = Join-Path $RepoRoot 'docs' 'context-assessment.md'

if (-not (Test-Path -Path $ContextAssessment -PathType Leaf)) {
    Write-Error "Context assessment not found at $ContextAssessment. Run setup-context-assessment.ps1 first."
    exit 1
}

$Summary = Get-AssessmentSummary

$SupportedAgents = @(
    'claude', 'gemini', 'copilot', 'cursor-agent', 'qwen', 'opencode', 'codex',
    'windsurf', 'kilocode', 'auggie', 'roo', 'codebuddy', 'amp', 'shai', 'q',
    'bob', 'jules', 'qoder', 'antigravity'
)

if ($AgentType) {
    $AgentType = $AgentType.ToLower()
    $agentFile = Get-AgentFile -Agent $AgentType
    if (-not $agentFile) {
        Write-Error "Unknown agent type: $AgentType. Supported: $($SupportedAgents -join ', ')"
        exit 1
    }
    Update-AgentFile -AgentKey $AgentType -AgentFile $agentFile -Summary $Summary
} else {
    $updated = 0
    foreach ($agentKey in $SupportedAgents) {
        $agentFile = Get-AgentFile -Agent $agentKey
        if ($agentFile -and (Test-Path -Path $agentFile -PathType Leaf)) {
            Update-AgentFile -AgentKey $agentKey -AgentFile $agentFile -Summary $Summary
            $updated++
        }
    }

    if ($updated -eq 0) {
        Write-Warning 'No agent files found in repository'
        Write-Host 'INFO: Create an agent file first, then run this script' -ForegroundColor Green
    } else {
        Write-Host "INFO: ✓ Updated $updated agent file(s)" -ForegroundColor Green
    }
}

Write-Host 'INFO: ✓ Agent context update complete' -ForegroundColor Green
