<#
.SYNOPSIS
    Validate Command Script - Validates agent command files for correctness.

.DESCRIPTION
    Validates agent command files (.md or .toml) against the Agent Command
    Creation Rules, checking frontmatter, description, arguments, and structure.

.PARAMETER Path
    Path to a .md or .toml command file.

.EXAMPLE
    .\validate-command.ps1 -Path .claude/commands/specify.md
    .\validate-command.ps1 -Path .gemini/commands/analyze.toml

.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (Windows/macOS/Linux)
    Author:   Dau Quang Thanh
    Version:  1.0
    License:  MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

# ── Constants ──────────────────────────────────────────────────────
$MAX_DESCRIPTION_LENGTH = 80
$MIN_DESCRIPTION_LENGTH = 10

# ── Helper functions ────────────────────────────────────────────────
function Write-Pass {
    param([string]$Check, [string]$Msg)
    Write-Host ("✅ PASS | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Green
}

function Write-Fail {
    param([string]$Check, [string]$Msg)
    Write-Host ("❌ FAIL | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Red
}

function Write-Warn {
    param([string]$Check, [string]$Msg)
    Write-Host ("⚠  WARN | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Yellow
}

function Write-InfoMsg {
    param([string]$Check, [string]$Msg)
    Write-Host ("ℹ  INFO | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Blue
}

function Write-Header {
    param([string]$Msg)
    Write-Host ""
    Write-Host $Msg -ForegroundColor Magenta -BackgroundColor Black
}

# ── Extract frontmatter value ──────────────────────────────────────
function Get-FrontmatterValue {
    param([string]$Content, [string]$Key)

    if ($Content -match '(?s)^---\r?\n(.*?)\r?\n---') {
        $frontmatter = $Matches[1]
        if ($frontmatter -match "(?m)^${Key}:\s*(.+)$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

# ── Validate file name ─────────────────────────────────────────────
function Test-FileName {
    param([string]$FilePath)
    $success = $true

    $fileName = Split-Path -Leaf $FilePath
    $ext = [System.IO.Path]::GetExtension($fileName).TrimStart('.')
    $name = [System.IO.Path]::GetFileNameWithoutExtension($fileName)

    # Handle .prompt.md extension
    if ($fileName -match '\.prompt\.md$') {
        $ext = "md"
        $name = $fileName -replace '\.prompt\.md$', ''
    }

    # Check extension
    if ($ext -ne "md" -and $ext -ne "toml") {
        Write-Fail "File Extension" "Invalid extension '.$ext'. Must be .md or .toml"
        $success = $false
    }
    else {
        Write-Pass "File Extension" ".$ext"
    }

    # Check naming convention
    if ($name -notmatch '^[a-z0-9]+([-.][a-z0-9]+)*$') {
        Write-Warn "File Name" "Name '$name' should be lowercase with hyphens/dots"
    }
    else {
        Write-Pass "File Name" "'$name'"
    }

    return $success
}

# ── Validate Markdown command ──────────────────────────────────────
function Test-MarkdownCommand {
    param([string]$Content)
    $success = $true

    # 1. Frontmatter check
    if (-not $Content.StartsWith("---")) {
        Write-Fail "Frontmatter" "Missing YAML frontmatter (must start with ---)"
        return $false
    }

    # Check closing frontmatter
    $lines = $Content -split "`n"
    $endLine = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq "---") {
            $endLine = $i
            break
        }
    }

    if ($endLine -eq -1) {
        Write-Fail "Frontmatter" "Unclosed YAML frontmatter"
        return $false
    }
    Write-Pass "Frontmatter" "Valid frontmatter found"

    # 2. Description check
    $description = Get-FrontmatterValue -Content $Content -Key "description"
    if ([string]::IsNullOrEmpty($description)) {
        Write-Fail "Description" "Missing required field: description"
        $success = $false
    }
    else {
        $descLen = $description.Length
        if ($descLen -lt $MIN_DESCRIPTION_LENGTH) {
            Write-Warn "Description" "Too short ($descLen chars < $MIN_DESCRIPTION_LENGTH)"
        }
        elseif ($descLen -gt $MAX_DESCRIPTION_LENGTH) {
            Write-Warn "Description" "Too long ($descLen chars > $MAX_DESCRIPTION_LENGTH)"
        }
        else {
            Write-Pass "Description" "Valid ($descLen chars)"
        }
    }

    # 3. Arguments placeholder check
    $body = ($lines[($endLine + 1)..($lines.Count - 1)]) -join "`n"
    if ($body -notmatch '\$ARGUMENTS') {
        Write-InfoMsg "Arguments" "Missing '`$ARGUMENTS' placeholder. Ensure you handle inputs if needed."
    }
    else {
        Write-Pass "Arguments" "'`$ARGUMENTS' placeholder found"
    }

    return $success
}

# ── Validate TOML command ──────────────────────────────────────────
function Test-TomlCommand {
    param([string]$Content)
    $success = $true

    # 1. Description check
    if ($Content -notmatch '(?m)^description\s*=') {
        Write-Fail "Description" "Missing required key: description"
        $success = $false
    }
    else {
        if ($Content -match '(?m)^description\s*=\s*["\x27](.+?)["\x27]') {
            $desc = $Matches[1]
            $descLen = $desc.Length
            if ($descLen -lt $MIN_DESCRIPTION_LENGTH) {
                Write-Warn "Description" "Too short ($descLen chars < $MIN_DESCRIPTION_LENGTH)"
            }
            else {
                Write-Pass "Description" "Valid ($descLen chars)"
            }
        }
        else {
            Write-Pass "Description" "Description key found"
        }
    }

    # 2. Prompt check
    if ($Content -notmatch 'prompt') {
        Write-Fail "Prompt" "Missing required key: prompt"
        $success = $false
    }
    else {
        Write-Pass "Prompt" "Prompt key found"
    }

    # 3. Arguments placeholder check
    if ($Content -notmatch '\{\{args\}\}') {
        Write-InfoMsg "Arguments" "Missing '{{args}}' placeholder in TOML content"
    }
    else {
        Write-Pass "Arguments" "'{{args}}' placeholder found"
    }

    return $success
}

# ── Main ───────────────────────────────────────────────────────────
if (-not (Test-Path $Path -PathType Leaf)) {
    Write-Host "Error: File not found: $Path" -ForegroundColor Red
    exit 1
}

$fileName = Split-Path -Leaf $Path
$fileExt = [System.IO.Path]::GetExtension($fileName).TrimStart('.')

Write-Header "Validating: $fileName"

$content = Get-Content -Path $Path -Raw -Encoding UTF8
$hasErrors = $false

# File name validation
if (-not (Test-FileName -FilePath $Path)) {
    $hasErrors = $true
}

# Content validation based on extension
if ($fileExt -eq "md") {
    if (-not (Test-MarkdownCommand -Content $content)) {
        $hasErrors = $true
    }
}
elseif ($fileExt -eq "toml") {
    if (-not (Test-TomlCommand -Content $content)) {
        $hasErrors = $true
    }
}

Write-Host "──────────────────────────────────────────────────"
if ($hasErrors) {
    Write-Host "🚫 VALIDATION FAILED: Please fix errors shown above." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "✅ VALIDATION PASSED: No issues found." -ForegroundColor Green
    exit 0
}
