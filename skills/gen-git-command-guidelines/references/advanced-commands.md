# Advanced Git Commands

## Overview

This reference covers advanced git operations that are less frequently used but essential for complex scenarios: cherry-pick, bisect, worktrees, submodules, reflog, and more.

## Cherry-Pick

Apply specific commits from one branch to another without merging the entire branch.

### Basic Usage

```bash
# Apply a single commit
git cherry-pick <sha>

# Apply multiple commits
git cherry-pick <sha1> <sha2> <sha3>

# Apply a range of commits (exclusive start, inclusive end)
git cherry-pick <start-sha>..<end-sha>

# Apply without committing (stage changes only)
git cherry-pick --no-commit <sha>
```

### Common Scenarios

```bash
# Backport a fix to a release branch
git checkout release/v2.0
git cherry-pick abc1234    # SHA of the fix on main

# Cherry-pick with conflict resolution
git cherry-pick <sha>
# Resolve conflicts...
git add <file>
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort
```

### Caution

Cherry-pick creates a new commit with a different SHA. Avoid cherry-picking between branches that will later be merged — it can cause duplicate changes. Prefer merge or rebase when possible.

## Git Bisect

Binary search through commits to find which one introduced a bug.

### Basic Workflow

```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark a known good commit
git bisect good v1.0.0

# Git checks out a middle commit — test it
# If it's good:
git bisect good
# If it's bad:
git bisect bad

# Repeat until Git identifies the first bad commit
# Output: abc1234 is the first bad commit

# End bisect
git bisect reset
```

### Automated Bisect

```bash
# Run a test script automatically
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
git bisect run npm test

# Git automatically finds the commit that broke the tests
```

### Tips

- Bisect works best with small, atomic commits
- The test script should exit 0 for good, non-0 for bad
- Use `git bisect skip` if a commit can't be tested
- Use `git bisect log` to review steps taken

## Git Worktrees

Work on multiple branches simultaneously without switching or stashing.

### Basic Usage

```bash
# Create a worktree for a branch
git worktree add ../project-hotfix hotfix/security-patch

# List worktrees
git worktree list

# Remove a worktree
git worktree remove ../project-hotfix

# Prune stale worktree references
git worktree prune
```

### Use Cases

```bash
# Work on a hotfix while keeping feature work untouched
git worktree add ../hotfix-dir hotfix/urgent-fix
cd ../hotfix-dir
# Fix, commit, push
cd ../main-project
git worktree remove ../hotfix-dir

# Run tests on another branch without switching
git worktree add ../test-branch release/v2.0
cd ../test-branch && npm test
```

### Limitations

- Each branch can only be checked out in one worktree
- Worktrees share the same `.git` directory
- Submodules may need manual initialization in new worktrees

## Git Submodules

Include external repositories within your project.

### Adding Submodules

```bash
# Add a submodule
git submodule add <url> path/to/submodule
git commit -m "chore: add submodule for shared-lib"

# Clone a repo with submodules
git clone --recurse-submodules <url>

# Initialize submodules after clone
git submodule init
git submodule update
```

### Updating Submodules

```bash
# Update all submodules to latest
git submodule update --remote

# Update specific submodule
git submodule update --remote path/to/submodule

# Pull changes within a submodule
cd path/to/submodule
git pull origin main
cd ..
git add path/to/submodule
git commit -m "chore: update shared-lib submodule"
```

### Removing Submodules

```bash
# Remove submodule entry
git submodule deinit path/to/submodule
git rm path/to/submodule
rm -rf .git/modules/path/to/submodule
git commit -m "chore: remove shared-lib submodule"
```

## Git Reflog

View the history of HEAD movements — your safety net for recovering lost work.

### Basic Usage

```bash
# Show reflog
git reflog

# Output:
# abc1234 HEAD@{0}: commit: feat: add search
# def5678 HEAD@{1}: rebase (finish)
# ghi9012 HEAD@{2}: rebase (start)
# jkl3456 HEAD@{3}: commit: fix: login bug
# mno7890 HEAD@{4}: checkout: moving from main to feature

# Show reflog for a specific branch
git reflog show feature/search

# Show reflog with timestamps
git reflog --date=relative
```

### Recovery Scenarios

```bash
# Recover from accidental reset --hard
git reflog
# Find the commit before the reset
git reset --hard HEAD@{2}

# Recover a deleted branch
git reflog
# Find the last commit on the deleted branch
git checkout -b recovered-branch HEAD@{5}

# Recover from bad rebase
git reflog
# Find pre-rebase commit
git reset --hard HEAD@{3}
```

### Reflog Expiration

By default, reflog entries expire after 90 days (30 days for unreachable commits). Configure with:

```bash
git config gc.reflogExpire 180.days
git config gc.reflogExpireUnreachable 90.days
```

## Git Blame and Log Forensics

### Blame

```bash
# Show who changed each line
git blame <file>

# Blame a specific line range
git blame -L 10,20 <file>

# Ignore whitespace changes
git blame -w <file>

# Follow renames
git blame -C <file>
```

### Advanced Log

```bash
# Search commit messages
git log --grep="search term"

# Search code changes (pickaxe)
git log -S "function_name"        # Find when string was added/removed
git log -G "regex_pattern"        # Find when pattern changed

# File history (follow renames)
git log --follow <file>

# Graph view
git log --oneline --graph --all

# Changes by author
git log --author="name" --oneline

# Changes in date range
git log --after="2026-01-01" --before="2026-03-01"

# Show diff stats
git log --stat
git log --shortstat
```

## Git Clean

Remove untracked files from the working directory.

```bash
# Dry run — show what would be deleted
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Remove ignored files too
git clean -fdx

# Interactive mode
git clean -i
```

**Warning**: `git clean` permanently deletes files. Always run with `-n` (dry run) first.

## Git Tags

### Creating Tags

```bash
# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Lightweight tag
git tag v1.0.0

# Tag a specific commit
git tag -a v1.0.0 abc1234 -m "Release version 1.0.0"
```

### Managing Tags

```bash
# List tags
git tag
git tag -l "v1.*"

# Push tags
git push origin v1.0.0           # Push specific tag
git push origin --tags            # Push all tags

# Delete tags
git tag -d v1.0.0                 # Local
git push origin --delete v1.0.0   # Remote
```

## Git Stash Advanced

```bash
# Stash including untracked files
git stash -u

# Stash including ignored files
git stash -a

# Create a branch from stash
git stash branch new-branch stash@{0}

# Show stash diff
git stash show -p stash@{0}

# Apply stash to a different branch
git checkout other-branch
git stash apply stash@{0}
```

## Git Hooks

Automate actions at specific points in the git workflow.

### Common Hooks

| Hook | Trigger | Use Case |
|------|---------|----------|
| `pre-commit` | Before commit | Lint, format, test |
| `commit-msg` | After message entry | Validate message format |
| `pre-push` | Before push | Run full test suite |
| `post-merge` | After merge | Install dependencies |
| `post-checkout` | After checkout | Update dependencies |

### Setup

```bash
# Hooks live in .git/hooks/
# Create a pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
npm run lint
EOF
chmod +x .git/hooks/pre-commit

# Use a hook manager (recommended)
# husky, lefthook, or pre-commit framework
npx husky init
```
