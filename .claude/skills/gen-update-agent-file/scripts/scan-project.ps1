<#
.SYNOPSIS
    Scans a project directory and outputs a summary of its structure,
    technologies, agents, and skills for use by gen-update-agent-file.
.PARAMETER Path
    Project root directory to scan (default: current directory).
.EXAMPLE
    .\scripts\scan-project.ps1 -Path C:\Projects\my-app
.NOTES
    Platforms: Windows PowerShell 5.1+, PowerShell 7+ (cross-platform)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = "."
)

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Directory not found: $Path"
    exit 1
}

Push-Location $Path
try {
    $root = (Get-Location).Path

    Write-Host "=== PROJECT SCAN REPORT ==="
    Write-Host "Root: $root"
    Write-Host ""

    # --- 1. Project Identity ---
    Write-Host "--- PROJECT IDENTITY ---"
    $depFiles = @("package.json", "pyproject.toml", "Cargo.toml", "go.mod", "pom.xml", "composer.json", "Gemfile")
    foreach ($f in $depFiles) {
        if (Test-Path $f) {
            Write-Host "Dependency file: $f"
        }
    }
    # Check for .csproj files
    Get-ChildItem -Filter "*.csproj" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Dependency file: $($_.Name)"
    }
    Write-Host ""

    # --- 2. Directory Structure ---
    Write-Host "--- DIRECTORY STRUCTURE ---"
    $excludeDirs = @("node_modules", ".git", "__pycache__", ".venv", ".next", "dist", "build", "target", ".cache")
    Get-ChildItem -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        Where-Object {
            $skip = $false
            foreach ($ex in $excludeDirs) {
                if ($_.FullName -match [regex]::Escape($ex)) { $skip = $true; break }
            }
            -not $skip
        } |
        ForEach-Object {
            $relative = $_.FullName.Substring($root.Length + 1)
            Write-Host "  $relative"
        }
    Write-Host ""

    # --- 3. Technology Detection ---
    Write-Host "--- TECHNOLOGIES ---"
    Write-Host "Languages detected:"
    $extensions = @("py", "ts", "tsx", "js", "jsx", "rs", "go", "java", "kt", "cs", "rb", "php")
    foreach ($ext in $extensions) {
        $count = (Get-ChildItem -Filter "*.$ext" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch "node_modules|\.git|\.venv" } |
            Select-Object -First 50).Count
        if ($count -gt 0) {
            Write-Host "  .$ext`: $count files"
        }
    }

    Write-Host "Config files:"
    $configs = @(
        "tsconfig.json", "tailwind.config.js", "tailwind.config.ts",
        ".eslintrc.js", ".eslintrc.json", "eslint.config.js",
        "Dockerfile", "docker-compose.yml", "docker-compose.yaml", ".env.example",
        "vite.config.ts", "vite.config.js", "webpack.config.js",
        "next.config.js", "next.config.ts", "nuxt.config.ts",
        "angular.json", "vue.config.js",
        ".markdownlint-cli2.jsonc", ".prettierrc", ".editorconfig"
    )
    foreach ($cfg in $configs) {
        if (Test-Path $cfg) {
            Write-Host "  $cfg"
        }
    }
    Write-Host ""

    # --- 4. Agent Ecosystem ---
    Write-Host "--- AGENTS ---"
    $agentDirs = @("agents", ".claude\agents", ".github\agents", ".cursor\agents")
    foreach ($dir in $agentDirs) {
        if (Test-Path $dir -PathType Container) {
            Write-Host "Agent directory: $dir/"
            Get-ChildItem -Path $dir -Filter "*.md" -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne "README.md" } |
                ForEach-Object {
                    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                    $name = if ($content -match '(?m)^name:\s*(.+)') { $Matches[1].Trim() } else { $_.BaseName }
                    $desc = if ($content -match '(?m)^description:\s*(.+)') { $Matches[1].Trim() } else { "No description" }
                    Write-Host "  Agent: $name - $desc"
                }
        }
    }
    Write-Host ""

    Write-Host "--- SKILLS ---"
    $skillDirs = @("skills", ".claude\skills", ".github\skills", ".cursor\skills")
    foreach ($dir in $skillDirs) {
        if (Test-Path $dir -PathType Container) {
            Write-Host "Skills directory: $dir/"
            Get-ChildItem -Path $dir -Recurse -Filter "SKILL.md" -Depth 1 -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $skillName = $_.Directory.Name
                    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                    $desc = if ($content -match '(?m)^description:\s*["\x27]?(.+?)["\x27]?\s*$') {
                        $Matches[1].Substring(0, [Math]::Min(120, $Matches[1].Length))
                    } else { "No description" }
                    Write-Host "  Skill: $skillName - $desc"
                }
        }
    }
    Write-Host ""

    # --- 5. CI/CD ---
    Write-Host "--- CI/CD ---"
    if (Test-Path ".github\workflows" -PathType Container) {
        Write-Host "GitHub Actions workflows:"
        Get-ChildItem -Path ".github\workflows" -Filter "*.yml" -ErrorAction SilentlyContinue |
            ForEach-Object { Write-Host "  $($_.Name)" }
        Get-ChildItem -Path ".github\workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue |
            ForEach-Object { Write-Host "  $($_.Name)" }
    }
    if ((Test-Path "CODEOWNERS") -or (Test-Path ".github\CODEOWNERS")) {
        Write-Host "CODEOWNERS: present"
    }
    Write-Host ""

    # --- 6. Existing Agent Files ---
    Write-Host "--- EXISTING AGENT FILES ---"
    foreach ($f in @("CLAUDE.md", "AGENTS.md")) {
        if (Test-Path $f) {
            $lines = (Get-Content $f).Count
            Write-Host "$f`: exists ($lines lines)"
            $content = Get-Content $f -Raw -ErrorAction SilentlyContinue
            if ($content -match '<!-- TEMPLATE') {
                Write-Host "  Mode: TEMPLATE (contains template markers)"
            } elseif ($content -match '\{\{') {
                Write-Host "  Mode: TEMPLATE (contains placeholders)"
            } else {
                Write-Host "  Mode: FREEFORM"
            }
        } else {
            Write-Host "$f`: NOT FOUND"
        }
    }
    Write-Host ""

    Write-Host "--- TEMPLATES ---"
    foreach ($f in @("templates\agent-file-template.md", "templates\AI-Agents-Configs.md")) {
        if (Test-Path $f) {
            Write-Host "Template found: $f"
        }
    }
    Write-Host ""

    # --- 7. Recent Git History ---
    Write-Host "--- RECENT COMMITS ---"
    try {
        $gitLog = & git log --oneline -10 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host $gitLog
        } else {
            Write-Host "  (no git history)"
        }
    } catch {
        Write-Host "  (not a git repository)"
    }
    Write-Host ""

    Write-Host "=== SCAN COMPLETE ==="
} finally {
    Pop-Location
}
