# Branching Strategies

## Overview

Choosing the right branching strategy depends on team size, release cadence, and project complexity. This reference covers the three most common strategies with guidance on when to use each.

## Git Flow

**Best for**: Teams with scheduled releases, long-lived projects, multiple versions in production.

### Branch Structure

```
main ─────────────────────────────────────── (production)
  └── develop ────────────────────────────── (integration)
        ├── feature/user-auth ────────────── (feature work)
        ├── feature/search ───────────────── (feature work)
        └── release/v2.1 ────────────────── (release prep)
  └── hotfix/security-patch ──────────────── (urgent fix)
```

### Branch Rules

| Branch | Created From | Merges Into | Lifetime |
|--------|-------------|-------------|----------|
| `main` | — | — | Permanent |
| `develop` | `main` | — | Permanent |
| `feature/*` | `develop` | `develop` | Temporary |
| `release/*` | `develop` | `main` + `develop` | Temporary |
| `hotfix/*` | `main` | `main` + `develop` | Temporary |

### Workflow

```bash
# Start a feature
git checkout develop
git checkout -b feature/user-auth

# Complete feature
git checkout develop
git merge --no-ff feature/user-auth
git branch -d feature/user-auth

# Prepare release
git checkout develop
git checkout -b release/v2.1
# ... bump versions, final testing ...
git checkout main
git merge --no-ff release/v2.1
git tag -a v2.1.0 -m "Release v2.1.0"
git checkout develop
git merge --no-ff release/v2.1
git branch -d release/v2.1

# Hotfix
git checkout main
git checkout -b hotfix/security-patch
# ... apply fix ...
git checkout main
git merge --no-ff hotfix/security-patch
git tag -a v2.1.1 -m "Hotfix v2.1.1"
git checkout develop
git merge --no-ff hotfix/security-patch
git branch -d hotfix/security-patch
```

### Pros and Cons

| Pros | Cons |
|------|------|
| Clear separation of concerns | Complex with many branches |
| Supports parallel development | Slow for continuous delivery |
| Good for versioned releases | Merge conflicts between long-lived branches |

## GitHub Flow

**Best for**: Teams practicing continuous delivery, small teams, SaaS products.

### Branch Structure

```
main ─────────────────────────────────────── (always deployable)
  ├── feature/user-auth ──────────────────── (short-lived)
  └── fix/login-crash ────────────────────── (short-lived)
```

### Rules

1. `main` is always deployable
2. Branch from `main` for any change
3. Open a pull request early
4. Merge to `main` after review + CI passes
5. Deploy immediately after merge

### Workflow

```bash
# Start work
git checkout main
git pull origin main
git checkout -b feature/user-auth

# Push and create PR
git push -u origin feature/user-auth
# Create PR via GitHub/GitLab UI or CLI

# After approval and CI passes
git checkout main
git pull origin main
git merge --squash feature/user-auth
git commit -m "feat(auth): add OAuth2 authentication"
git push origin main

# Clean up
git branch -d feature/user-auth
git push origin --delete feature/user-auth
```

### Pros and Cons

| Pros | Cons |
|------|------|
| Simple and easy to understand | No release branch concept |
| Fast feedback loop | Requires robust CI/CD |
| Encourages small, frequent changes | Less suited for versioned releases |

## Trunk-Based Development

**Best for**: Experienced teams, high deployment frequency, strong CI/CD.

### Branch Structure

```
main ─────────────────────────────────────── (trunk)
  ├── short-lived/user-auth ──────────────── (< 2 days)
  └── short-lived/fix-crash ──────────────── (< 1 day)
```

### Rules

1. `main` (trunk) is the single source of truth
2. Branches live less than 2 days
3. Merge to trunk at least daily
4. Use feature flags for incomplete features
5. Release from trunk (or short-lived release branches)

### Workflow

```bash
# Start short-lived branch
git checkout main
git pull --rebase origin main
git checkout -b short-lived/user-auth

# Work in small increments, merge quickly
git add .
git commit -m "feat(auth): add login form skeleton (behind flag)"
git push -u origin short-lived/user-auth

# Merge same day or next day
git checkout main
git pull --rebase origin main
git merge short-lived/user-auth
git push origin main
git branch -d short-lived/user-auth
```

### Pros and Cons

| Pros | Cons |
|------|------|
| Minimal merge conflicts | Requires feature flags |
| Fast integration | Needs strong CI/CD and test coverage |
| Simple branch model | Discipline required for small changes |

## Strategy Comparison

| Factor | Git Flow | GitHub Flow | Trunk-Based |
|--------|----------|-------------|-------------|
| Complexity | High | Low | Low |
| Release cadence | Scheduled | Continuous | Continuous |
| Team size | Large | Small-Medium | Any (with discipline) |
| Branch lifetime | Long | Medium | Short (<2 days) |
| Versioning | Explicit (tags) | Implicit | Feature flags |
| CI/CD requirement | Moderate | High | Very High |

## Choosing a Strategy

**Use Git Flow when:**
- You ship versioned releases (v1.0, v2.0)
- Multiple versions are in production
- You need clear release preparation phases

**Use GitHub Flow when:**
- You deploy on every merge to main
- Team is small to medium
- You want simplicity

**Use Trunk-Based when:**
- You deploy multiple times per day
- Team has strong testing practices
- You can implement feature flags

## Migration Between Strategies

### Git Flow to GitHub Flow

1. Stop creating new `develop` branches
2. Merge `develop` into `main`
3. Branch features directly from `main`
4. Set up CI/CD to deploy on merge to `main`

### GitHub Flow to Trunk-Based

1. Shorten branch lifetimes to < 2 days
2. Implement feature flag system
3. Increase CI/CD pipeline speed
4. Enforce merge-to-trunk-daily policy
