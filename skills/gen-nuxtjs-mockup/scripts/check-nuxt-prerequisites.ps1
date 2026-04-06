<#
.SYNOPSIS
    Nuxt.js Mockup Prerequisites Checker.
.DESCRIPTION
    Verifies Node.js, package manager (npm/pnpm/yarn), and existing project detection.
.PARAMETER Json
    Output results in JSON format.
.EXAMPLE
    .\scripts\check-nuxt-prerequisites.ps1
.EXAMPLE
    .\scripts\check-nuxt-prerequisites.ps1 -Json
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
$PnpmVersion = ''
$YarnVersion = ''
$NpmVersion = ''
$NuxtProject = $false
$AllOk = $true
$Errors = @()

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

# Check Node.js
try {
    $nodeOut = & node --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $nodeOut) {
        $NodeAvailable = $true
        $NodeVersion = $nodeOut -replace '^v', ''
        $NodeMajor = [int]($NodeVersion.Split('.')[0])
        if ($NodeMajor -lt 18) {
            $AllOk = $false
            $Errors += "Node.js version $NodeVersion is too old. Nuxt 4 requires Node.js 18.0.0 or higher"
        }
    }
} catch {
    # Node.js not available
}

if (-not $NodeAvailable) {
    $AllOk = $false
    $Errors += 'Node.js not found. Install from https://nodejs.org/ (v20+ recommended)'
}

# Check package managers (pnpm preferred, then yarn, then npm)
try {
    $pnpmOut = & pnpm --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $pnpmOut) {
        $PnpmVersion = $pnpmOut.Trim()
        if (-not $PkgManager) {
            $PkgManager = 'pnpm'
            $PkgVersion = $PnpmVersion
        }
    }
} catch {}

try {
    $yarnOut = & yarn --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $yarnOut) {
        $YarnVersion = $yarnOut.Trim()
        if (-not $PkgManager) {
            $PkgManager = 'yarn'
            $PkgVersion = $YarnVersion
        }
    }
} catch {}

try {
    $npmOut = & npm --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $npmOut) {
        $NpmVersion = $npmOut.Trim()
        if (-not $PkgManager) {
            $PkgManager = 'npm'
            $PkgVersion = $NpmVersion
        }
    }
} catch {}

if (-not $PkgManager) {
    $AllOk = $false
    $Errors += 'No package manager found. npm should be bundled with Node.js'
}

# Check for existing Nuxt project
$packageJson = Join-Path $WorkspaceRoot 'package.json'
if (Test-Path $packageJson -PathType Leaf) {
    $content = Get-Content -Path $packageJson -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content -and $content -match '"nuxt"') {
        $NuxtProject = $true
    }
}

# Output
if ($Json) {
    $result = @{
        success         = $AllOk
        workspace_root  = $WorkspaceRoot
        node            = @{
            available     = $NodeAvailable
            version       = $NodeVersion
            major_version = $NodeMajor
        }
        package_manager = @{
            name          = $PkgManager
            version       = $PkgVersion
            npm_version   = $NpmVersion
            pnpm_version  = $PnpmVersion
            yarn_version  = $YarnVersion
        }
        project         = @{
            is_nuxt = $NuxtProject
        }
        errors          = $Errors
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Host ''
    Write-Host 'Nuxt.js Mockup - Prerequisites Check'
    Write-Host '=================================================='
    Write-Host ''
    Write-Host "Workspace: $WorkspaceRoot"
    Write-Host ''

    # Node.js
    Write-Host 'Node.js:'
    if ($NodeAvailable) {
        Write-Host "  ✓ Node.js installed (v$NodeVersion)"
        if ($NodeMajor -ge 18) {
            Write-Host '  ✓ Version meets requirements (18+)'
        } else {
            Write-Host "  ✗ Version too old (need 18+, have $NodeMajor)"
        }
    } else {
        Write-Host '  ✗ Node.js not found (REQUIRED)'
    }
    Write-Host ''

    # Package Manager
    Write-Host 'Package Manager:'
    if ($PkgManager) {
        Write-Host "  ✓ $PkgManager v$PkgVersion detected"
        if ($PnpmVersion) { Write-Host '  ✓ pnpm available (recommended)' }
        if ($YarnVersion -and $PkgManager -ne 'yarn') { Write-Host "    yarn v$YarnVersion also available" }
        if ($NpmVersion -and $PkgManager -ne 'npm') { Write-Host "    npm v$NpmVersion also available" }
    } else {
        Write-Host '  ✗ No package manager found (REQUIRED)'
    }
    Write-Host ''

    # Project status
    Write-Host 'Project Status:'
    if ($NuxtProject) {
        Write-Host '  ✓ Existing Nuxt project detected'
    } else {
        Write-Host '    No Nuxt project detected (will initialize new project)'
    }
    Write-Host ''

    # Summary
    if ($AllOk) {
        Write-Host '✓ All prerequisites met. Ready to create Nuxt mockups!'
        Write-Host ''
        Write-Host 'Next steps:'
        Write-Host '  1. Run skill to create mockup project'
        Write-Host "  2. Or manually initialize: $PkgManager create nuxt@latest mockup"
        Write-Host "  3. Install dependencies: cd mockup && $PkgManager install"
        Write-Host "  4. Start dev server: $PkgManager dev"
    } else {
        Write-Host '✗ Missing required prerequisites:'
        foreach ($err in $Errors) {
            Write-Host "  - $err"
        }
        Write-Host ''
        Write-Host 'Installation Tips:'
        if (-not $NodeAvailable) {
            Write-Host '  - Install Node.js v20 LTS: https://nodejs.org/'
            Write-Host '  - Or use version manager: nvm install 20'
        } elseif ($NodeMajor -lt 18) {
            Write-Host '  - Upgrade Node.js: nvm install 20 && nvm use 20'
        }
        if (-not $PnpmVersion) {
            Write-Host '  - Install pnpm (recommended): npm install -g pnpm'
        }
        exit 1
    }
    Write-Host ''
}
