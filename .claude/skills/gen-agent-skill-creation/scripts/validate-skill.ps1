<#
.SYNOPSIS
    Validate Skill Script - Validates agent skills against the specification.

.DESCRIPTION
    Validates an agent skill directory structure, frontmatter, description quality,
    file references, and script compatibility against the Agent Skills specification.

.PARAMETER Path
    Path to skill directory or directory containing multiple skills.

.EXAMPLE
    .\validate-skill.ps1 -Path ./my-skill
    .\validate-skill.ps1 -Path ./skills/pdf-processing

.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (Windows/macOS/Linux)
    Author:   ODC-X Platform
    Version:  1.0
    License:  MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

# ── Helper functions ────────────────────────────────────────────────
function Write-Pass {
    param([string]$Check, [string]$Msg)
    Write-Host ("✅ PASS | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Green
}

function Write-Fail {
    param([string]$Check, [string]$Msg)
    Write-Host ("❌ FAIL | {0,-25} {1}" -f $Check, $Msg) -ForegroundColor Red
}

function Write-Header {
    param([string]$Msg)
    Write-Host ""
    Write-Host $Msg -ForegroundColor Magenta -BackgroundColor Black
}

# ── Extract frontmatter value ───────────────────────────────────────
function Get-FrontmatterValue {
    param([string]$Content, [string]$Key)

    # Extract frontmatter between --- markers
    if ($Content -match '(?s)^---\r?\n(.*?)\r?\n---') {
        $frontmatter = $Matches[1]
        # Match top-level key (not indented)
        if ($frontmatter -match "(?m)^${Key}:\s*(.+)$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

function Get-MetadataValue {
    param([string]$Content, [string]$Key)

    if ($Content -match '(?s)^---\r?\n(.*?)\r?\n---') {
        $frontmatter = $Matches[1]
        if ($frontmatter -match "(?m)^\s+${Key}:\s*(.+)$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

# ── Validate a single skill ────────────────────────────────────────
function Test-Skill {
    param([string]$SkillPath)

    $skillName = Split-Path -Leaf $SkillPath
    $success = $true

    Write-Header "Validating Skill: $skillName"
    Write-Host "Path: $(Resolve-Path $SkillPath)"

    $skillMd = Join-Path $SkillPath "SKILL.md"

    # 1. Structure check
    if (-not (Test-Path $skillMd -PathType Leaf)) {
        Write-Fail "Structure Check" "SKILL.md missing"
        Write-Host "──────────────────────────────────────────────────"
        return $false
    }
    Write-Pass "Structure Check" "Structure OK"

    # Read content
    $content = Get-Content -Path $skillMd -Raw -Encoding UTF8
    $lines = (Get-Content -Path $skillMd -Encoding UTF8)
    $lineCount = $lines.Count

    # 2. Size validation
    if ($lineCount -gt 500) {
        Write-Fail "SKILL.md Size" "$lineCount lines (> 500 limit). Move details to references/."
        $success = $false
    }
    else {
        Write-Pass "SKILL.md Size" "$lineCount lines"
    }

    # 3. Frontmatter check
    if (-not $content.StartsWith("---")) {
        Write-Fail "Frontmatter" "No frontmatter found (must start with ---)"
        $success = $false
    }
    else {
        Write-Pass "Frontmatter" "Valid frontmatter found"

        # Name validation
        $name = Get-FrontmatterValue -Content $content -Key "name"
        if ([string]::IsNullOrEmpty($name)) {
            Write-Fail "Meta: 'name'" "Missing required field"
            $success = $false
        }
        elseif ($name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
            Write-Fail "Meta: 'name'" "Invalid format '$name'. Use lowercase, hyphens only."
            $success = $false
        }
        elseif ($name -ne $skillName) {
            Write-Fail "Meta: 'name'" "Mismatch: '$name' != dir '$skillName'"
            $success = $false
        }
        else {
            Write-Pass "Meta: 'name'" "'$name'"
        }

        # Description validation
        $description = Get-FrontmatterValue -Content $content -Key "description"
        if ([string]::IsNullOrEmpty($description)) {
            Write-Fail "Meta: 'description'" "Missing required field"
            $success = $false
        }
        else {
            $descLen = $description.Length
            if ($descLen -gt 1024) {
                Write-Fail "Meta: 'description'" "Too long ($descLen chars > 1024)"
                $success = $false
            }
            elseif ($descLen -lt 10) {
                Write-Fail "Meta: 'description'" "Too short (< 10 chars)"
                $success = $false
            }
            else {
                $qualityIssues = @()
                if ($description -notmatch "(?i)Use when|Use for") {
                    $qualityIssues += "Missing 'Use when...' clause"
                }
                if ($description -notmatch "(?i)mention|keyword") {
                    $qualityIssues += "Missing 'user mentions...' clause"
                }
                if ($description -match "(?i)helps with|tool for|does stuff") {
                    $qualityIssues += "Contains vague term"
                }

                if ($qualityIssues.Count -gt 0) {
                    Write-Pass "Meta: 'description'" "Valid but weak: $($qualityIssues -join ', ')"
                }
                else {
                    Write-Pass "Meta: 'description'" "Follows best practices"
                }
            }
        }

        # Last updated validation
        $lastUpdated = Get-MetadataValue -Content $content -Key "last_updated"
        if ($lastUpdated -and $lastUpdated -notmatch '^\d{4}-\d{2}-\d{2}$') {
            Write-Fail "Meta: 'last_updated'" "Invalid date $lastUpdated. Use YYYY-MM-DD."
            $success = $false
        }
    }

    # 4. File reference validation
    $brokenLinks = @()
    $linkPattern = '\[.*?\]\((.*?)\)'
    $matches_found = [regex]::Matches($content, $linkPattern)
    foreach ($m in $matches_found) {
        $link = $m.Groups[1].Value
        if ($link -match '^(http|#|/|mailto:)') { continue }
        $cleanLink = ($link -split '#')[0] -split '\?' | Select-Object -First 1
        if ([string]::IsNullOrEmpty($cleanLink)) { continue }
        $targetPath = Join-Path $SkillPath $cleanLink
        if (-not (Test-Path $targetPath)) {
            $brokenLinks += $cleanLink
        }
    }

    if ($brokenLinks.Count -gt 0) {
        $display = ($brokenLinks | Select-Object -First 3) -join ', '
        if ($brokenLinks.Count -gt 3) { $display += "..." }
        Write-Fail "File References" "Broken links: $display"
        $success = $false
    }
    else {
        Write-Pass "File References" "All internal links valid"
    }

    # 5. Script validation
    $scriptsDir = Join-Path $SkillPath "scripts"
    if (Test-Path $scriptsDir -PathType Container) {
        $scriptIssues = @()
        $bannedFiles = @()
        $bannedExtensions = @('.py', '.rb', '.js', '.ts', '.pl', '.php', '.lua')

        Get-ChildItem -Path $scriptsDir -File | Where-Object { $_.Name -notlike '.*' } | ForEach-Object {
            # Check for banned script formats (only .sh and .ps1 allowed)
            if ($_.Extension -in $bannedExtensions) {
                $bannedFiles += $_.Name
            }
        }

        if ($bannedFiles.Count -gt 0) {
            Write-Fail "Scripts Check" "Banned formats (only .sh/.ps1 allowed): $($bannedFiles -join ', ')"
            $success = $false
        }
        elseif ($scriptIssues.Count -gt 0) {
            Write-Fail "Scripts Check" "Issues: $($scriptIssues -join ', ')"
        }
        else {
            Write-Pass "Scripts Check" "Scripts look compatible"
        }
    }

    Write-Host "──────────────────────────────────────────────────"
    if ($success) {
        Write-Host "✅ SKILL VALID" -ForegroundColor Green
    }
    else {
        Write-Host "🚫 SKILL INVALID: Please fix errors shown in red above." -ForegroundColor Red
    }

    return $success
}

# ── Main logic ──────────────────────────────────────────────────────
if (-not (Test-Path $Path)) {
    Write-Host "Error: Path not found: $Path" -ForegroundColor Red
    exit 1
}

if (Test-Path (Join-Path $Path "SKILL.md") -PathType Leaf) {
    # Single skill mode
    $result = Test-Skill -SkillPath $Path
    if (-not $result) { exit 1 }
}
else {
    # Directory mode
    Write-Host "Scanning directory: $Path"
    $failures = 0
    $total = 0

    Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -notlike '.*' } | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "SKILL.md") -PathType Leaf) {
            $total++
            $result = Test-Skill -SkillPath $_.FullName
            if (-not $result) { $failures++ }
        }
    }

    if ($total -eq 0) {
        Write-Host "No skills found (folders with SKILL.md)"
        exit 1
    }

    Write-Host ""
    Write-Host "Summary:"
    Write-Host "Total Skills: $total"
    Write-Host "Passed:       $($total - $failures)"
    Write-Host "Failed:       $failures"

    if ($failures -gt 0) { exit 1 }
}
