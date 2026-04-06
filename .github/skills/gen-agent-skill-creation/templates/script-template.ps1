<#
.SYNOPSIS
    [Script Name] - [Brief description]

.DESCRIPTION
    This script [what it does in one sentence].

.PARAMETER Input
    Input file path (required).

.PARAMETER Output
    Output file path. If omitted, writes to stdout.

.PARAMETER Format
    Output format: text, json, csv. Default: text.

.PARAMETER Verbose
    Enable verbose output.

.PARAMETER Quiet
    Suppress non-error output.

.EXAMPLE
    .\script-name.ps1 -Input input.txt
    .\script-name.ps1 -Input input.txt -Output result.txt
    .\script-name.ps1 -Input data.csv -Format json -Verbose

.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (Windows/macOS/Linux)
    Author:   [Your Name]
    Version:  1.0
    License:  MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Input,

    [Parameter()]
    [string]$Output,

    [Parameter()]
    [ValidateSet("text", "json", "csv")]
    [string]$Format = "text",

    [Parameter()]
    [switch]$Quiet
)

# ── Exit codes ──────────────────────────────────────────────────────
$EXIT_SUCCESS = 0
$EXIT_ERROR   = 1
$EXIT_USAGE   = 2

# ── Helper functions ────────────────────────────────────────────────
function Write-Success { param([string]$Msg) Write-Host "✓ $Msg" -ForegroundColor Green }
function Write-Err     { param([string]$Msg) Write-Host "✗ $Msg" -ForegroundColor Red }
function Write-Info    { param([string]$Msg) Write-Host "ℹ $Msg" -ForegroundColor Blue }
function Write-Warn    { param([string]$Msg) Write-Host "⚠ $Msg" -ForegroundColor Yellow }

# ── Validation ──────────────────────────────────────────────────────
if (-not (Test-Path -Path $Input -PathType Leaf)) {
    Write-Err "Input file not found: $Input"
    exit $EXIT_ERROR
}

# ── Main logic ──────────────────────────────────────────────────────
try {
    if ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Info "Processing $Input..."
    }

    # Read input file
    $Content = Get-Content -Path $Input -Raw -Encoding UTF8

    # Replace this with your actual processing logic
    switch ($Format) {
        "json" { $Result = "{`"content`": `"$Content`"}" }
        "csv"  { $Result = "content`n$Content" }
        default { $Result = $Content }
    }

    # Write output
    if ($Output) {
        $Result | Out-File -FilePath $Output -Encoding UTF8 -NoNewline
        if ($VerbosePreference -ne 'SilentlyContinue') {
            Write-Info "Output written to: $Output"
        }
    }
    else {
        Write-Output $Result
    }

    if (-not $Quiet) {
        Write-Success "Success"
    }

    exit $EXIT_SUCCESS
}
catch {
    Write-Err "Error: $_"
    exit $EXIT_ERROR
}
