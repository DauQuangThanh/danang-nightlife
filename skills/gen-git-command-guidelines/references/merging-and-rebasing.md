# Merging and Rebasing

## Overview

Understanding when to merge vs rebase is critical for maintaining a clean, understandable git history. This reference covers both operations in depth with decision guidance.

## Merge vs Rebase Decision Matrix

| Scenario | Use Merge | Use Rebase |
|----------|-----------|------------|
| Shared/public branch | Yes | No |
| Feature branch (solo) | Optional | Yes (preferred) |
| Feature branch (team) | Yes | Only before push |
| Incorporating upstream changes | Optional | Yes (preferred) |
| Preserving branch history | Yes | No |
| Clean linear history | No | Yes |

## Merging

### Fast-Forward Merge

When the target branch has no new commits since branching:

```bash
# Before: main hasn't moved
# main:    A---B
# feature:       C---D

git checkout main
git merge feature

# After: main pointer moves forward
# main:    A---B---C---D
```

### No-Fast-Forward Merge

Forces a merge commit even when fast-forward is possible:

```bash
git merge --no-ff feature

# Creates explicit merge commit
# main:    A---B-------M
# feature:       C---D/
```

**When to use `--no-ff`:**
- Team convention requires merge commits
- You want to preserve feature branch history
- Using Git Flow strategy

### Squash Merge

Combines all feature commits into a single commit on the target:

```bash
git merge --squash feature
git commit -m "feat(auth): add OAuth2 authentication"

# Before:
# main:    A---B
# feature:       C---D---E

# After:
# main:    A---B---F  (F contains C+D+E changes)
```

**When to use `--squash`:**
- Feature branch has messy commit history
- You want one clean commit per feature
- PR-based workflow where individual commits don't matter

### Merge Strategies

```bash
# Recursive (default) — handles most cases
git merge feature

# Ours — keep our version for all conflicts
git merge -s ours feature

# Octopus — merge multiple branches at once
git merge feature-a feature-b feature-c
```

## Rebasing

### Basic Rebase

Replays your commits on top of the target branch:

```bash
# Before:
# main:    A---B---E---F
# feature:       C---D

git checkout feature
git rebase main

# After:
# main:    A---B---E---F
# feature:               C'---D'
```

**Key point**: Rebase creates NEW commits (C' and D') with different SHAs.

### Interactive Rebase

Clean up commit history before merging:

```bash
git rebase -i HEAD~4
```

Editor opens with:

```
pick abc1234 feat: add search index
pick def5678 fix: typo in search
pick ghi9012 feat: add search UI
pick jkl3456 fix: search styling
```

**Commands:**

| Command | Effect |
|---------|--------|
| `pick` | Keep commit as-is |
| `reword` | Keep commit, edit message |
| `edit` | Pause to amend commit |
| `squash` | Combine with previous commit |
| `fixup` | Like squash but discard message |
| `drop` | Remove commit entirely |
| `reorder` | Move lines to reorder commits |

**Example: Squash fix commits into feature commits:**

```
pick abc1234 feat: add search index
fixup def5678 fix: typo in search
pick ghi9012 feat: add search UI
fixup jkl3456 fix: search styling
```

Result: 2 clean commits instead of 4.

### Rebase onto

Move a branch to a different base:

```bash
# Before:
# main:     A---B---C
# feature:       D---E
# topic:              F---G

# Move topic from feature to main
git rebase --onto main feature topic

# After:
# main:     A---B---C---F'---G'
# feature:       D---E
```

**Use cases:**
- Moving a branch to a different parent
- Removing intermediate commits
- Fixing a branch that was started from the wrong base

## Conflict Resolution During Rebase

Rebase replays commits one at a time, so conflicts are resolved per-commit:

```bash
git rebase main

# Conflict occurs
# 1. Fix conflicts in files
# 2. Stage resolved files
git add <file>

# 3. Continue rebase
git rebase --continue

# Or abort entirely
git rebase --abort

# Or skip the problematic commit
git rebase --skip
```

**Tip**: Conflicts during rebase can feel repetitive if the same lines conflict in multiple commits. Consider squashing related commits first with interactive rebase, then rebasing onto the target.

## Rebase Safety Rules

### Never Rebase Public/Shared Commits

```bash
# DANGEROUS: These commits are on a shared branch
git rebase main     # If current branch has been pushed and others are using it

# SAFE: Local-only commits
git rebase main     # If commits haven't been pushed yet
```

### The Golden Rule

> Do not rebase commits that exist outside your repository and that people may have based work on.

### Recovery from Bad Rebase

```bash
# Find the pre-rebase state
git reflog

# Output:
# abc1234 HEAD@{0}: rebase (finish): ...
# def5678 HEAD@{1}: rebase (start): ...
# ghi9012 HEAD@{2}: commit: my last commit before rebase

# Reset to pre-rebase state
git reset --hard ghi9012
```

## Autosquash Workflow

For a streamlined fixup workflow:

```bash
# Make a commit that references a previous one
git commit --fixup=abc1234

# Later, interactive rebase automatically arranges fixups
git rebase -i --autosquash main
```

Enable globally:

```bash
git config --global rebase.autoSquash true
```

## Pull with Rebase

Prefer rebase when pulling to avoid unnecessary merge commits:

```bash
# Instead of:
git pull origin main          # Creates merge commits

# Use:
git pull --rebase origin main  # Replays local commits on top

# Set as default:
git config --global pull.rebase true
```

## Merge vs Rebase Workflow Examples

### Workflow A: Rebase + Merge (Recommended for most teams)

```bash
# 1. Develop on feature branch
git checkout -b feature/search

# 2. Before merging, rebase onto latest main
git fetch origin
git rebase origin/main

# 3. Merge with no-ff to preserve feature boundary
git checkout main
git merge --no-ff feature/search
```

Result: Linear history within feature, clear merge points.

### Workflow B: Squash Merge (Recommended for PR-based teams)

```bash
# 1. Develop on feature branch (messy commits OK)
git checkout -b feature/search

# 2. Squash merge via PR or command line
git checkout main
git merge --squash feature/search
git commit -m "feat(search): add full-text search"
```

Result: One commit per feature, very clean main history.

### Workflow C: Rebase Only (For experienced teams)

```bash
# 1. Develop on feature branch
git checkout -b feature/search

# 2. Interactive rebase to clean up
git rebase -i main

# 3. Fast-forward merge
git checkout main
git merge feature/search
```

Result: Completely linear history, no merge commits.
