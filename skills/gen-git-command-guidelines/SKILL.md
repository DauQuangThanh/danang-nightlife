---
name: gen-git-command-guidelines
description: "Provides git command guidelines, branching strategies, and workflow best practices. Use when setting up git workflows, resolving merge conflicts, managing branches, or when user mentions git commands, branching, rebasing, cherry-pick, or git workflows."
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "1.0.0"
  last_updated: "2026-02-08"
  category: implementation
  tags: "git, version-control, branching, merging, rebasing, workflows"
---

# Git Command Guidelines

## Overview

This skill provides comprehensive git command guidelines, covering branching strategies, common workflows, conflict resolution, and advanced operations. It ensures teams follow consistent, safe git practices across projects.

## When to Use

- Setting up or enforcing git branching strategies
- Resolving merge conflicts or rebase issues
- Performing advanced git operations (cherry-pick, bisect, stash, reflog)
- Onboarding developers to team git workflows
- When user mentions "git commands", "branching", "rebasing", or "git workflow"

## Prerequisites

- Git 2.30+ installed
- Familiarity with basic version control concepts
- Repository initialized with `git init` or cloned

## Core Commands Quick Reference

### Repository Setup

```bash
# Initialize a new repository
git init

# Clone an existing repository
git clone <url>
git clone --depth 1 <url>          # Shallow clone (faster)
git clone --branch <name> <url>    # Clone specific branch
```

### Daily Workflow

```bash
# Check status and changes
git status                         # Working tree status
git diff                           # Unstaged changes
git diff --staged                  # Staged changes

# Stage changes
git add <file>                     # Stage specific file
git add -p                         # Interactive staging (patch mode)

# Commit
git commit -m "type(scope): message"
git commit --amend                 # Amend last commit (unpushed only)

# Sync with remote
git fetch origin                   # Download remote changes
git pull --rebase origin main      # Pull with rebase (preferred)
git push origin <branch>           # Push branch to remote
```

### Branching

```bash
# Create and switch branches
git checkout -b feature/my-feature     # Create + switch
git switch -c feature/my-feature       # Modern alternative (Git 2.23+)

# List branches
git branch                             # Local branches
git branch -r                          # Remote branches
git branch -a                          # All branches

# Delete branches
git branch -d <branch>                 # Safe delete (merged only)
git branch -D <branch>                 # Force delete
git push origin --delete <branch>      # Delete remote branch
```

### Merging

```bash
# Merge a branch
git merge <branch>                     # Merge into current branch
git merge --no-ff <branch>             # Force merge commit (no fast-forward)
git merge --squash <branch>            # Squash all commits into one

# Abort a merge
git merge --abort
```

### Rebasing

```bash
# Rebase current branch onto target
git rebase main                        # Rebase onto main
git rebase --onto main feature topic   # Rebase topic onto main

# Abort or continue
git rebase --abort
git rebase --continue
```

### Stashing

```bash
# Save work temporarily
git stash                              # Stash changes
git stash push -m "description"        # Stash with message
git stash list                         # List stashes
git stash pop                          # Apply + remove latest stash
git stash apply stash@{2}              # Apply specific stash
git stash drop stash@{0}              # Remove specific stash
```

## Branching Strategy

### Branch Naming Convention

| Prefix | Purpose | Example |
|--------|---------|---------|
| `main` | Production-ready code | `main` |
| `develop` | Integration branch | `develop` |
| `feature/` | New features | `feature/user-auth` |
| `fix/` | Bug fixes | `fix/login-crash` |
| `hotfix/` | Urgent production fixes | `hotfix/security-patch` |
| `release/` | Release preparation | `release/v2.1.0` |
| `chore/` | Maintenance tasks | `chore/update-deps` |

### Branch Lifecycle

1. **Create** from `main` or `develop`
2. **Develop** with small, focused commits
3. **Sync** regularly: `git pull --rebase origin main`
4. **Review** via pull request
5. **Merge** with squash or merge commit
6. **Delete** the branch after merge

## Safety Rules

### Commands That Are Safe

```bash
git status, git log, git diff, git fetch
git branch, git stash, git show, git blame
```

### Commands That Require Caution

```bash
# These modify history or discard work — use with care
git reset --hard              # Discards ALL uncommitted changes
git push --force              # Overwrites remote history
git rebase                    # Rewrites commit history
git clean -fd                 # Deletes untracked files permanently
git checkout -- <file>        # Discards uncommitted file changes
```

### Golden Rules

1. **Never force-push to shared branches** (`main`, `develop`)
2. **Never rebase commits that have been pushed** to shared branches
3. **Always fetch before merging or rebasing** to avoid conflicts
4. **Commit early, commit often** — small commits are easier to review and revert
5. **Write meaningful commit messages** (see gen-git-commit skill)
6. **Delete merged branches** to keep the repository clean
7. **Use `--rebase` when pulling** to maintain linear history

## Conflict Resolution

### Basic Conflict Workflow

```bash
# 1. Pull/merge triggers conflict
git pull --rebase origin main

# 2. Check which files have conflicts
git status

# 3. Open conflicted files, resolve markers:
#    <<<<<<< HEAD
#    (your changes)
#    =======
#    (incoming changes)
#    >>>>>>> branch-name

# 4. After resolving, mark as resolved
git add <resolved-file>

# 5. Continue the operation
git rebase --continue          # If rebasing
git merge --continue           # If merging (Git 2.12+)
git commit                     # If merging (older Git)
```

### Tips for Conflict Resolution

- Use `git diff --name-only --diff-filter=U` to list conflicted files
- Use `git checkout --ours <file>` or `git checkout --theirs <file>` to accept one side entirely
- Use `git mergetool` for visual conflict resolution
- For complex conflicts, consider `git rerere` to record resolutions

## Examples

### Example 1: Feature Development Workflow

```bash
# Start feature from main
git checkout main
git pull --rebase origin main
git checkout -b feature/add-search

# Work on feature with atomic commits
git add src/search.ts
git commit -m "feat(search): add search index builder"

git add src/search-ui.tsx
git commit -m "feat(search): add search results component"

# Sync with main before creating PR
git fetch origin
git rebase origin/main

# Push and create PR
git push -u origin feature/add-search
```

### Example 2: Hotfix Workflow

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-auth-bypass

# Fix and commit
git add src/auth/middleware.ts
git commit -m "fix(auth): close session token bypass vulnerability"

# Push and fast-track PR
git push -u origin hotfix/fix-auth-bypass
```

### Example 3: Recovering from Mistakes

```bash
# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Undo last commit (keep changes unstaged)
git reset HEAD~1

# Find lost commits via reflog
git reflog
git checkout <sha>

# Revert a pushed commit (creates new commit)
git revert <sha>
```

## Edge Cases

### Detached HEAD State

Occurs when checking out a commit SHA directly. Create a branch to preserve work:

```bash
git checkout -b recovery-branch
```

### Large File Accidentally Committed

Remove from history using `git filter-branch` or BFG Repo-Cleaner. Prevent with `.gitignore` and Git LFS.

### Diverged Branches

When local and remote have diverged, prefer rebase for feature branches:

```bash
git pull --rebase origin main
```

For shared branches, use merge to preserve history.

## Error Handling

### "Your local changes would be overwritten"

```bash
# Stash first, then retry
git stash
git pull --rebase origin main
git stash pop
```

### "Failed to push: non-fast-forward"

```bash
# Fetch and rebase, then push
git fetch origin
git rebase origin/main
git push origin <branch>
```

### "CONFLICT: Merge conflict in <file>"

See the Conflict Resolution section above. Never force-push to resolve — always fix conflicts properly.

### "fatal: refusing to merge unrelated histories"

```bash
git pull origin main --allow-unrelated-histories
```

## References

For detailed guidance, load these reference files as needed:

- **[branching-strategies.md](references/branching-strategies.md)**: Git Flow, GitHub Flow, Trunk-Based Development comparison
- **[merging-and-rebasing.md](references/merging-and-rebasing.md)**: When to merge vs rebase, interactive rebase guide
- **[advanced-commands.md](references/advanced-commands.md)**: Bisect, cherry-pick, worktrees, submodules, reflog
- **[collaboration-workflows.md](references/collaboration-workflows.md)**: PR workflows, code review with git, fork management
- **[troubleshooting.md](references/troubleshooting.md)**: Common errors, recovery procedures, data loss prevention
- **[best-practices.md](references/best-practices.md)**: Repository hygiene, .gitignore patterns, hooks, aliases
