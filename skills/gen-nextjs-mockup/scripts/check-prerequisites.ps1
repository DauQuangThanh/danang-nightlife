<#
.SYNOPSIS
    Next.js Mockup Prerequisites Checker.
.DESCRIPTION
    Verifies Node.js and package manager (npm/pnpm) availability.
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\check-prerequisites.ps1
.EXAMPLE
    .\scripts\check-prerequisites.ps1 -Json
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$NodeAvailable = $false
$NodeVersion = ''
$NodeMajor = 0
$PkgManager = ''
$PkgVersion = ''
$AllOk = $true

# Check Node.js
try {
    $nodeOut = & node --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $nodeOut) {
        $NodeAvailable = $true
        $NodeVersion = $nodeOut -replace '^v', ''
        $NodeMajor = [int]($NodeVersion.Split('.')[0])
    }
} catch {
    $AllOk = $false
}

if (-not $NodeAvailable) { $AllOk = $false }

# Check pnpm first (recommended), then npm
try {
    $pnpmOut = & pnpm --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $pnpmOut) {
        $PkgManager = 'pnpm'
        $PkgVersion = $pnpmOut.Trim()
    }
} catch {}

if (-not $PkgManager) {
    try {
        $npmOut = & npm --version 2>$null
        if ($LASTEXITCODE -eq 0 -and $npmOut) {
            $PkgManager = 'npm'
            $PkgVersion = $npmOut.Trim()
        }
    } catch {}
}

if (-not $PkgManager) { $AllOk = $false }

# Find workspace root
$WorkspaceRoot = (Get-Location).Path
$current = (Get-Location).Path
while ($current -ne [System.IO.Path]::GetPathRoot($current)) {
    if (Test-Path -Path (Join-Path $current '.git') -PathType Container) {
        $WorkspaceRoot = $current
        break
    }
    $current = Split-Path -Parent $current
}

if ($Json) {
    $result = @{
        node = @{
            available     = $NodeAvailable
            version       = $NodeVersion
            major_version = $NodeMajor
        }
        package_manager = @{
            name    = $PkgManager
            version = $PkgVersion
        }
        workspace_root = $WorkspaceRoot
        all_ok         = $AllOk
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host 'Next.js Mockup - Prerequisites Check'
    Write-Host '============================================='

    if ($NodeAvailable) {
        Write-Host "[OK] Node.js v$NodeVersion detected"
        if ($NodeMajor -lt 18) {
            Write-Host '[WARN] Node.js 18+ required, 20+ recommended'
            $AllOk = $false
        }
    } else {
        Write-Host '[FAIL] Node.js not found'
    }

    if ($PkgManager) {
        if ($PkgManager -eq 'pnpm') {
            Write-Host "[OK] pnpm v$PkgVersion detected (recommended)"
        } else {
            Write-Host "[OK] npm v$PkgVersion detected"
        }
    } else {
        Write-Host '[FAIL] No package manager found (npm or pnpm required)'
    }

    if ($AllOk) {
        Write-Host '[OK] All prerequisites met. Ready to create Next.js mockups!'
    } else {
        Write-Host '[FAIL] Some prerequisites are missing. Please install required tools.'
        exit 1
    }
}
