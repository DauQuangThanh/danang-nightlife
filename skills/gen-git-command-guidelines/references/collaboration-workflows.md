# Collaboration Workflows

## Overview

This reference covers git workflows for team collaboration: pull request best practices, code review with git, fork management, and team coordination patterns.

## Pull Request Workflow

### Creating a Good PR

```bash
# 1. Create feature branch
git checkout main
git pull --rebase origin main
git checkout -b feature/user-search

# 2. Make small, focused commits
git add src/search/index.ts
git commit -m "feat(search): add search index service"

git add src/search/ui.tsx
git commit -m "feat(search): add search results component"

# 3. Clean up before pushing
git fetch origin
git rebase origin/main

# 4. Push
git push -u origin feature/user-search

# 5. Create PR via CLI
gh pr create --title "feat(search): add user search" \
  --body "## Summary
- Add search index service
- Add search results component

## Test Plan
- [ ] Unit tests pass
- [ ] Manual search test"
```

### PR Size Guidelines

| Size | Lines Changed | Review Time | Recommendation |
|------|--------------|-------------|----------------|
| Small | < 200 | < 30 min | Ideal |
| Medium | 200-500 | 30-60 min | Acceptable |
| Large | 500-1000 | 1-2 hours | Split if possible |
| Too Large | > 1000 | > 2 hours | Must split |

### Stacked PRs

For large features, break into dependent PRs:

```bash
# PR 1: Data layer
git checkout -b feature/search-data
# ... commits ...
git push -u origin feature/search-data

# PR 2: Business logic (depends on PR 1)
git checkout feature/search-data
git checkout -b feature/search-logic
# ... commits ...
git push -u origin feature/search-logic

# PR 3: UI (depends on PR 2)
git checkout feature/search-logic
git checkout -b feature/search-ui
# ... commits ...
git push -u origin feature/search-ui
```

After PR 1 merges, rebase PR 2 onto main:

```bash
git checkout feature/search-logic
git rebase main
git push --force-with-lease origin feature/search-logic
```

## Code Review with Git

### Reviewing Changes

```bash
# View PR diff
gh pr diff 123

# Checkout PR locally for testing
gh pr checkout 123

# View changes between specific commits
git diff abc1234..def5678

# View changes in specific files
git diff main...feature/search -- src/search/

# Show stat summary
git diff --stat main...feature/search
```

### Suggesting Changes

```bash
# After checking out PR, make suggested changes
gh pr checkout 123
# Edit files...
git add -p                         # Stage specific hunks
git commit -m "review: suggested refactor for readability"
git push
```

### Review Commands

```bash
# Approve PR
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes --body "See inline comments"

# Comment without approving
gh pr review 123 --comment --body "Looks good, minor suggestions"
```

## Fork Management

### Setting Up a Fork

```bash
# Fork via CLI
gh repo fork owner/repo

# Clone your fork
git clone git@github.com:your-user/repo.git
cd repo

# Add upstream remote
git remote add upstream git@github.com:owner/repo.git

# Verify remotes
git remote -v
# origin    git@github.com:your-user/repo.git (fetch)
# origin    git@github.com:your-user/repo.git (push)
# upstream  git@github.com:owner/repo.git (fetch)
# upstream  git@github.com:owner/repo.git (push)
```

### Keeping Fork in Sync

```bash
# Fetch upstream changes
git fetch upstream

# Update main from upstream
git checkout main
git rebase upstream/main
git push origin main

# Update feature branch
git checkout feature/my-change
git rebase main
```

### Contributing via Fork

```bash
# Create feature branch
git checkout -b feature/fix-typo

# Make changes and push to your fork
git add .
git commit -m "docs: fix typo in README"
git push origin feature/fix-typo

# Create PR against upstream
gh pr create --repo owner/repo \
  --title "docs: fix typo in README" \
  --body "Fixed typo in installation section"
```

## Team Coordination Patterns

### Shared Feature Branch

When multiple developers work on the same feature:

```bash
# Developer A creates the feature branch
git checkout -b feature/big-feature
git push -u origin feature/big-feature

# Developer B works on the same branch
git fetch origin
git checkout feature/big-feature

# Both developers pull frequently
git pull --rebase origin feature/big-feature

# Important: Use --force-with-lease (not --force) when rebasing
git push --force-with-lease origin feature/big-feature
```

### Integration Branch Pattern

For complex features with sub-teams:

```bash
# Create integration branch
git checkout -b integration/v3-redesign

# Sub-team branches
git checkout -b feature/v3-api           # Team A
git checkout -b feature/v3-frontend      # Team B
git checkout -b feature/v3-migration     # Team C

# Teams merge into integration branch
git checkout integration/v3-redesign
git merge --no-ff feature/v3-api

# Final merge to main when all sub-features complete
git checkout main
git merge --no-ff integration/v3-redesign
```

### Release Coordination

```bash
# Create release branch
git checkout -b release/v2.1 develop

# Only bug fixes allowed on release branch
git cherry-pick <bugfix-sha>

# When ready, merge to main and tag
git checkout main
git merge --no-ff release/v2.1
git tag -a v2.1.0 -m "Release v2.1.0"

# Back-merge to develop
git checkout develop
git merge --no-ff release/v2.1
```

## Force Push Safety

### `--force-with-lease` vs `--force`

```bash
# DANGEROUS: Overwrites remote unconditionally
git push --force origin feature/my-branch

# SAFE: Only overwrites if remote matches your last fetch
git push --force-with-lease origin feature/my-branch
```

`--force-with-lease` fails if someone else pushed to the branch since your last fetch. Always use this instead of `--force`.

### When Force Push Is Acceptable

- Your own feature branch that no one else is using
- After interactive rebase on a solo branch
- After amending the last commit on a solo branch

### When Force Push Is Never Acceptable

- `main` or `develop` branches
- Shared feature branches
- Any branch others might have checked out

## Protected Branch Configuration

### GitHub Branch Protection Rules

Recommended settings for `main`:

- Require pull request reviews (at least 1)
- Require status checks to pass
- Require branches to be up to date before merging
- Require signed commits (optional, high-security teams)
- Do not allow force pushes
- Do not allow deletions

```bash
# Configure via GitHub CLI
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field required_status_checks='{"strict":true,"contexts":["ci/test"]}' \
  --field enforce_admins=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```
