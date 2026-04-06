# Best Practices

## Overview

Repository hygiene, .gitignore patterns, useful aliases, hooks, and conventions that keep git workflows clean and efficient.

## Repository Hygiene

### Keep the Repository Clean

1. **Delete merged branches** promptly
2. **Use `.gitignore`** before first commit
3. **Never commit secrets** (API keys, passwords, tokens)
4. **Use Git LFS** for large binary files (>1 MB)
5. **Keep commits atomic** — one logical change per commit

### Branch Cleanup

```bash
# Delete local branches that have been merged
git branch --merged main | grep -v "main\|develop" | xargs git branch -d

# Delete remote tracking branches that no longer exist
git fetch --prune
# or configure auto-prune
git config --global fetch.prune true

# Find stale branches (older than 3 months)
git for-each-ref --sort=committerdate refs/heads/ \
  --format='%(committerdate:short) %(refname:short)' | head -20
```

### Repository Size Management

```bash
# Check repository size
git count-objects -vH

# Find large files in history
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  grep '^blob' | sort -k3 -n | tail -20

# Set up Git LFS
git lfs install
git lfs track "*.zip" "*.tar.gz" "*.psd" "*.ai" "*.mov"
git add .gitattributes
```

## .gitignore Patterns

### Essential .gitignore Template

```gitignore
# OS files
.DS_Store
Thumbs.db
Desktop.ini

# Editor/IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Environment and secrets
.env
.env.local
.env.*.local
*.pem
*.key
credentials.json

# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc
.venv/
venv/

# Build output
dist/
build/
out/
target/
bin/
obj/

# Logs
*.log
logs/

# Test coverage
coverage/
.nyc_output/
htmlcov/

# Package manager locks (choose one per ecosystem)
# Keep: package-lock.json OR yarn.lock (not both)
```

### .gitignore Tips

```bash
# Generate .gitignore for your stack
# Visit gitignore.io or use:
curl -sL https://www.toptal.com/developers/gitignore/api/node,python,macos > .gitignore

# Global .gitignore for personal files
git config --global core.excludesfile ~/.gitignore_global

# Debug: check why a file is ignored
git check-ignore -v <file>

# Track a file that's in .gitignore
git add -f <file>
```

## Useful Git Aliases

### Setup

```bash
# Add aliases to git config
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.df diff
git config --global alias.lg "log --oneline --graph --all --decorate"
```

### Recommended Aliases

```bash
[alias]
    # Short forms
    st = status
    co = checkout
    br = branch
    ci = commit
    df = diff
    
    # Log variants
    lg = log --oneline --graph --all --decorate
    ll = log --oneline -20
    last = log -1 HEAD --stat
    
    # Branch management
    branches = branch -a
    remotes = remote -v
    stale = "!git branch --merged main | grep -v main"
    cleanup = "!git branch --merged main | grep -v main | xargs git branch -d"
    
    # Working directory
    unstage = reset HEAD --
    discard = checkout --
    amend = commit --amend --no-edit
    
    # Diff shortcuts
    staged = diff --staged
    words = diff --word-diff
    
    # Show what I did today
    today = log --since='00:00:00' --oneline --author='me'
    
    # Find commits by message
    find = log --all --grep
    
    # Show branch contributors
    who = shortlog -sne
```

## Git Hooks

### Pre-commit Hook

Run linting and formatting before each commit:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

set -euo pipefail

echo "Running pre-commit checks..."

# Lint staged files only
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if echo "$STAGED_FILES" | grep -qE '\.(js|ts|tsx)$'; then
    echo "Linting JavaScript/TypeScript..."
    npx eslint $(echo "$STAGED_FILES" | grep -E '\.(js|ts|tsx)$')
fi

if echo "$STAGED_FILES" | grep -qE '\.(py)$'; then
    echo "Linting Python..."
    ruff check $(echo "$STAGED_FILES" | grep -E '\.py$')
fi

echo "Pre-commit checks passed!"
```

### Commit-msg Hook

Validate conventional commit format:

```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg

COMMIT_MSG=$(cat "$1")
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .{1,50}'

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "ERROR: Commit message does not follow conventional format."
    echo "Expected: type(scope): subject"
    echo "Example:  feat(auth): add login endpoint"
    echo ""
    echo "Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
    exit 1
fi
```

### Using Hook Managers

Rather than manual hooks, use a hook manager:

```bash
# Husky (Node.js projects)
npx husky init
echo "npx lint-staged" > .husky/pre-commit

# Lefthook (any project)
brew install lefthook
lefthook install

# pre-commit framework (Python ecosystem)
pip install pre-commit
pre-commit install
```

## Commit Best Practices

### Atomic Commits

Each commit should be:
- **Self-contained**: Can be reverted without breaking other changes
- **Focused**: Addresses a single concern
- **Buildable**: Code compiles and tests pass at every commit

### Commit Checklist

Before committing, verify:

- [ ] Changes are related to a single purpose
- [ ] No debug code (`console.log`, `print`, `debugger`)
- [ ] No commented-out code
- [ ] No secrets or credentials
- [ ] No large binary files
- [ ] Tests pass
- [ ] Linter passes
- [ ] Commit message follows conventions

### Staging Strategies

```bash
# Stage specific files
git add src/auth/login.ts src/auth/login.test.ts

# Interactive staging (select specific changes)
git add -p

# Stage all changes in a directory
git add src/auth/

# Unstage a file
git reset HEAD <file>
```

## Configuration Recommendations

### Essential Global Config

```bash
# Identity
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Default branch name
git config --global init.defaultBranch main

# Pull strategy
git config --global pull.rebase true

# Auto-prune on fetch
git config --global fetch.prune true

# Better diff algorithm
git config --global diff.algorithm histogram

# Auto-stash during rebase
git config --global rebase.autoStash true

# Auto-squash fixup commits
git config --global rebase.autoSquash true

# Color output
git config --global color.ui auto

# Default editor
git config --global core.editor "code --wait"    # VS Code
# git config --global core.editor "vim"           # Vim
# git config --global core.editor "nano"          # Nano
```

### Signing Commits

```bash
# Set up GPG signing
git config --global user.signingkey <GPG-KEY-ID>
git config --global commit.gpgsign true

# Or use SSH signing (Git 2.34+)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

## Security Best Practices

### Never Commit Secrets

```bash
# Use git-secrets to prevent secret commits
brew install git-secrets
git secrets --install
git secrets --register-aws    # Scans for AWS keys

# Scan existing history
git secrets --scan-history
```

### If You Accidentally Committed a Secret

```bash
# 1. Immediately rotate the credential

# 2. Remove from history using BFG
brew install bfg
bfg --replace-text passwords.txt repo.git

# 3. Force push (coordinate with team)
git push --force-with-lease --all

# 4. Force garbage collection
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Verify Commits

```bash
# Verify a signed commit
git verify-commit <sha>

# Show signature in log
git log --show-signature

# Require signed commits in GitHub branch protection
```
