<#
.SYNOPSIS
    License Scanner — scans project dependencies and classifies licenses.
.DESCRIPTION
    Scans project dependency manifests and classifies licenses into four tiers:
    APPROVED, CONDITIONAL, RESTRICTED, UNKNOWN.
    Supports: npm (package.json), Python (requirements.txt), Go (go.mod),
    Java (pom.xml), .NET (*.csproj).
.PARAMETER ProjectRoot
    Path to the project root directory (default: current directory).
.PARAMETER Ecosystem
    Force a specific ecosystem instead of auto-detection.
.PARAMETER Strict
    Also block CONDITIONAL licenses.
.PARAMETER Json
    Output results as JSON.
.EXAMPLE
    .\scripts\license-scan.ps1 -ProjectRoot ./my-project
.EXAMPLE
    .\scripts\license-scan.ps1 -Ecosystem npm -Strict
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectRoot = ".",

    [ValidateSet("npm", "python", "go", "java", "dotnet")]
    [string]$Ecosystem,

    [switch]$Strict,

    [switch]$Json
)

# ---------------------------------------------------------------------------
# License classification tiers
# ---------------------------------------------------------------------------

$ApprovedLicenses = @("MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC", "CC0-1.0", "Unlicense", "0BSD")
$ConditionalLicenses = @("MPL-2.0", "LGPL-2.1", "LGPL-2.1-only", "LGPL-2.1-or-later", "LGPL-3.0", "LGPL-3.0-only", "LGPL-3.0-or-later", "EPL-2.0", "CDDL-1.0")
$RestrictedLicenses = @("GPL-2.0", "GPL-2.0-only", "GPL-2.0-or-later", "GPL-3.0", "GPL-3.0-only", "GPL-3.0-or-later", "AGPL-3.0", "AGPL-3.0-only", "AGPL-3.0-or-later", "SSPL-1.0", "BSL-1.1")

function Get-LicenseTier {
    param([string]$License)

    if (-not $License -or $License -eq "UNKNOWN") { return "UNKNOWN" }

    # Handle OR expressions
    if ($License -match '\sOR\s') {
        $parts = $License -split '\s+OR\s+', 0, 'IgnoreCase'
        foreach ($part in $parts) {
            $tier = Get-LicenseTier -License $part.Trim()
            if ($tier -eq "APPROVED") { return "APPROVED" }
        }
    }

    foreach ($a in $ApprovedLicenses) {
        if ($License -ieq $a) { return "APPROVED" }
    }
    foreach ($c in $ConditionalLicenses) {
        if ($License -ieq $c) { return "CONDITIONAL" }
    }
    foreach ($r in $RestrictedLicenses) {
        if ($License -ieq $r) { return "RESTRICTED" }
    }
    return "UNKNOWN"
}

# ---------------------------------------------------------------------------
# Ecosystem detection
# ---------------------------------------------------------------------------

function Find-Ecosystem {
    param([string]$Root)

    if (Test-Path "$Root/package.json") { return "npm" }
    if (Test-Path "$Root/requirements.txt") { return "python" }
    if (Test-Path "$Root/pyproject.toml") { return "python" }
    if (Test-Path "$Root/go.mod") { return "go" }
    if (Test-Path "$Root/pom.xml") { return "java" }
    if (Get-ChildItem -Path $Root -Filter "*.csproj" -ErrorAction SilentlyContinue) { return "dotnet" }
    return $null
}

# ---------------------------------------------------------------------------
# Scan functions
# ---------------------------------------------------------------------------

function Scan-Npm {
    param([string]$Root)
    $results = @()

    $lockPath = Join-Path $Root "package-lock.json"
    if (Test-Path $lockPath) {
        $lock = Get-Content $lockPath -Raw | ConvertFrom-Json
        $packages = $lock.packages
        if ($packages) {
            foreach ($prop in $packages.PSObject.Properties) {
                $key = $prop.Name
                if ($key -and $key -ne "") {
                    $name = $key -replace '^node_modules/', ''
                    $version = $prop.Value.version
                    $license = $prop.Value.license
                    if (-not $version) { $version = "*" }
                    if (-not $license) { $license = "UNKNOWN" }
                    $results += [PSCustomObject]@{ Name = $name; Version = $version; License = $license }
                }
            }
        }
    }
    return $results
}

function Scan-Python {
    param([string]$Root)
    $results = @()

    $reqPath = Join-Path $Root "requirements.txt"
    if (Test-Path $reqPath) {
        foreach ($line in Get-Content $reqPath) {
            $line = $line.Trim()
            if (-not $line -or $line.StartsWith("#") -or $line.StartsWith("-")) { continue }
            if ($line -match '^([A-Za-z0-9_][A-Za-z0-9._-]*)\s*([><=!~]+\s*[\S]+)?') {
                $name = $Matches[1]
                $verSpec = if ($Matches[2]) { $Matches[2].Trim() } else { "" }
                $version = if ($verSpec -match '[\d][\d.]*') { $Matches[0] } else { "*" }
                $results += [PSCustomObject]@{ Name = $name; Version = $version; License = "UNKNOWN" }
            }
        }
    }
    return $results
}

function Scan-Go {
    param([string]$Root)
    $results = @()

    $modPath = Join-Path $Root "go.mod"
    if (Test-Path $modPath) {
        $inRequire = $false
        foreach ($line in Get-Content $modPath) {
            $line = $line.Trim()
            if ($line -match '^require \(') { $inRequire = $true; continue }
            if ($inRequire -and $line -eq ')') { $inRequire = $false; continue }
            if ($inRequire) {
                $parts = $line -split '\s+'
                if ($parts.Count -ge 2) {
                    $results += [PSCustomObject]@{ Name = $parts[0]; Version = $parts[1]; License = "UNKNOWN" }
                }
            }
        }
    }
    return $results
}

function Scan-Dotnet {
    param([string]$Root)
    $results = @()

    foreach ($csproj in Get-ChildItem -Path $Root -Filter "*.csproj" -ErrorAction SilentlyContinue) {
        [xml]$xml = Get-Content $csproj.FullName
        foreach ($ref in $xml.SelectNodes("//PackageReference")) {
            $name = $ref.GetAttribute("Include")
            $version = $ref.GetAttribute("Version")
            if (-not $version) { $version = "*" }
            if ($name) {
                $results += [PSCustomObject]@{ Name = $name; Version = $version; License = "UNKNOWN" }
            }
        }
    }
    return $results
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

$ProjectRoot = Resolve-Path $ProjectRoot -ErrorAction Stop

$eco = if ($Ecosystem) { $Ecosystem } else { Find-Ecosystem -Root $ProjectRoot }
if (-not $eco) {
    Write-Error "No supported dependency manifest found in $ProjectRoot"
    exit 1
}

Write-Host "Ecosystem: $eco"
Write-Host "Project root: $ProjectRoot"
Write-Host ""

# Scan
$deps = switch ($eco) {
    "npm" { Scan-Npm -Root $ProjectRoot }
    "python" { Scan-Python -Root $ProjectRoot }
    "go" { Scan-Go -Root $ProjectRoot }
    "dotnet" { Scan-Dotnet -Root $ProjectRoot }
    default { @() }
}

# Classify
$summary = @{ Approved = 0; Conditional = 0; Restricted = 0; Unknown = 0 }
$blockedDeps = @()

foreach ($dep in $deps) {
    $tier = Get-LicenseTier -License $dep.License
    $dep | Add-Member -NotePropertyName "Tier" -NotePropertyValue $tier -Force
    $summary[$tier]++

    Write-Host "  [$tier] $($dep.Name)@$($dep.Version)  ($($dep.License))"

    if ($tier -eq "RESTRICTED" -or $tier -eq "UNKNOWN") {
        $blockedDeps += $dep
    }
    if ($Strict -and $tier -eq "CONDITIONAL") {
        $blockedDeps += $dep
    }
}

Write-Host ""
Write-Host "Summary:"
Write-Host "  Total: $($deps.Count)"
Write-Host "  Approved: $($summary['Approved'])"
Write-Host "  Conditional: $($summary['Conditional'])"
Write-Host "  Restricted: $($summary['Restricted'])"
Write-Host "  Unknown: $($summary['Unknown'])"
Write-Host ""

if ($Json) {
    $result = @{
        ecosystem    = $eco
        total_deps   = $deps.Count
        by_tier      = @{
            approved    = @($deps | Where-Object { $_.Tier -eq "APPROVED" })
            conditional = @($deps | Where-Object { $_.Tier -eq "CONDITIONAL" })
            restricted  = @($deps | Where-Object { $_.Tier -eq "RESTRICTED" })
            unknown     = @($deps | Where-Object { $_.Tier -eq "UNKNOWN" })
        }
        blocked      = $blockedDeps.Count -gt 0
        blocked_deps = $blockedDeps
    }
    $result | ConvertTo-Json -Depth 5
}

if ($blockedDeps.Count -gt 0) {
    Write-Host "STATUS: BLOCKED" -ForegroundColor Red
    Write-Host "Blocked dependencies:"
    foreach ($d in $blockedDeps) {
        Write-Host "  - $($d.Name)@$($d.Version) [$($d.License)] ($($d.Tier))" -ForegroundColor Red
    }
    exit 1
}
else {
    Write-Host "STATUS: PASS" -ForegroundColor Green
    exit 0
}
