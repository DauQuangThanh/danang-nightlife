# Troubleshooting

## Overview

Common git errors, their causes, and step-by-step solutions. Organized by error message for quick lookup.

## Authentication and Connection Errors

### "Permission denied (publickey)"

**Cause**: SSH key not configured or not added to ssh-agent.

```bash
# Check if SSH key exists
ls -la ~/.ssh/id_ed25519.pub

# Generate new key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy output and add at github.com/settings/keys

# Test connection
ssh -T git@github.com
```

### "remote: Repository not found"

**Cause**: Wrong URL, private repo without access, or typo.

```bash
# Check remote URL
git remote -v

# Fix URL
git remote set-url origin git@github.com:correct/repo.git

# Verify access
gh repo view owner/repo
```

### "fatal: unable to access... SSL certificate problem"

```bash
# Temporary fix (not recommended for production)
git -c http.sslVerify=false clone <url>

# Proper fix: update CA certificates
# macOS
brew install ca-certificates

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install ca-certificates
```

## Push and Pull Errors

### "rejected — non-fast-forward"

**Cause**: Remote has commits you don't have locally.

```bash
# Option 1: Rebase (preferred for feature branches)
git fetch origin
git rebase origin/main
git push origin feature/my-branch

# Option 2: Merge
git pull origin main
git push origin feature/my-branch

# Option 3: Force push (ONLY for your own feature branch)
git push --force-with-lease origin feature/my-branch
```

### "Your local changes to the following files would be overwritten"

**Cause**: Uncommitted local changes conflict with incoming changes.

```bash
# Option 1: Stash, pull, unstash
git stash
git pull --rebase origin main
git stash pop

# Option 2: Commit first
git add .
git commit -m "wip: save current work"
git pull --rebase origin main

# Option 3: Discard local changes (DESTRUCTIVE)
git checkout -- <file>
git pull origin main
```

### "fatal: refusing to merge unrelated histories"

**Cause**: Two repositories with no common ancestor.

```bash
git pull origin main --allow-unrelated-histories
# Resolve any conflicts, then commit
```

## Merge and Rebase Errors

### "CONFLICT (content): Merge conflict in <file>"

```bash
# 1. See all conflicted files
git status
git diff --name-only --diff-filter=U

# 2. Open file, find conflict markers
# <<<<<<< HEAD
# your changes
# =======
# incoming changes
# >>>>>>> branch-name

# 3. Resolve: edit file, remove markers, keep correct code

# 4. Mark as resolved
git add <file>

# 5. Complete the operation
git merge --continue    # if merging
git rebase --continue   # if rebasing

# Abort if needed
git merge --abort
git rebase --abort
```

### "Cannot rebase: You have unstaged changes"

```bash
git stash
git rebase main
git stash pop
```

### "Could not apply <sha>... <message>"

**Cause**: Conflict during rebase at a specific commit.

```bash
# Check which files conflict
git status

# Resolve conflicts in each file
# Then:
git add <resolved-files>
git rebase --continue

# Or skip this commit
git rebase --skip

# Or abort entire rebase
git rebase --abort
```

## Branch Errors

### "fatal: A branch named '<name>' already exists"

```bash
# Delete the existing branch first
git branch -d <name>    # Safe delete (must be merged)
git branch -D <name>    # Force delete

# Then create
git checkout -b <name>
```

### "error: Cannot delete branch '<name>' checked out at..."

```bash
# Switch to a different branch first
git checkout main
git branch -d <name>
```

### "error: The branch '<name>' is not fully merged"

```bash
# Check what's not merged
git log main..<name>

# If you're sure you want to delete
git branch -D <name>

# Or merge first
git checkout main
git merge <name>
git branch -d <name>
```

## Commit Errors

### "nothing to commit, working tree clean"

**Cause**: No changes staged or all changes already committed.

```bash
# Check if you have unstaged changes
git status
git diff

# Check if changes are in a different directory
git status -u
```

### "Please enter a commit message to explain why this merge is necessary"

**Cause**: Git opened an editor for a merge commit message.

```bash
# In vim: type :wq to save and quit
# In nano: Ctrl+X, then Y, then Enter

# To avoid the editor:
git merge --no-edit <branch>
```

### Amending a Pushed Commit

```bash
# WARNING: Only do this on your own branch
git commit --amend -m "corrected message"
git push --force-with-lease origin <branch>
```

## Recovery Scenarios

### Recover Deleted Branch

```bash
# Find the last commit SHA
git reflog | grep "checkout: moving from <branch-name>"
# or
git reflog --all | grep <branch-name>

# Recreate the branch
git checkout -b <branch-name> <sha>
```

### Recover from `reset --hard`

```bash
# Find the commit you want to recover
git reflog

# Reset back to it
git reset --hard HEAD@{N}
```

### Undo Last Commit

```bash
# Keep changes staged
git reset --soft HEAD~1

# Keep changes unstaged
git reset HEAD~1

# Discard changes entirely (DESTRUCTIVE)
git reset --hard HEAD~1
```

### Recover Stashed Changes After `stash drop`

```bash
# Find dropped stash
git fsck --unreachable | grep commit

# Or more specifically
git log --graph --oneline --all $(git fsck --no-reflogs 2>/dev/null | grep "dangling commit" | cut -d' ' -f3)

# Apply the recovered commit
git stash apply <sha>
```

### Undo a Push

```bash
# Create a revert commit (safe — preserves history)
git revert <sha>
git push origin main

# Or reset and force push (DANGEROUS — only for your own branch)
git reset --hard HEAD~1
git push --force-with-lease origin <branch>
```

## Performance Issues

### Slow `git status`

```bash
# Enable filesystem monitor
git config core.fsmonitor true
git config core.untrackedCache true

# Check for large files
git rev-list --objects --all | git cat-file --batch-check | sort -k3 -n | tail -20
```

### Slow Clone

```bash
# Shallow clone
git clone --depth 1 <url>

# Clone only one branch
git clone --single-branch --branch main <url>

# Partial clone (blobs on demand)
git clone --filter=blob:none <url>
```

### Large Repository

```bash
# Use sparse checkout
git clone --no-checkout <url>
cd repo
git sparse-checkout init --cone
git sparse-checkout set src/myproject
git checkout main

# Use Git LFS for large files
git lfs install
git lfs track "*.psd"
git lfs track "*.zip"
git add .gitattributes
```

## Configuration Issues

### Wrong Author on Commits

```bash
# Set correct author for this repo
git config user.name "Your Name"
git config user.email "your@email.com"

# Fix last commit author
git commit --amend --author="Your Name <your@email.com>"

# Fix multiple commits (interactive rebase)
git rebase -i HEAD~5
# Change 'pick' to 'edit' for commits to fix
# For each: git commit --amend --author="..." && git rebase --continue
```

### Line Ending Issues

```bash
# Configure line endings
# On Windows:
git config --global core.autocrlf true
# On macOS/Linux:
git config --global core.autocrlf input

# Fix existing files
git add --renormalize .
git commit -m "fix: normalize line endings"
```

### `.gitignore` Not Working

```bash
# Files already tracked are not affected by .gitignore
# Remove from tracking (keep file locally)
git rm --cached <file>
git commit -m "chore: remove tracked file from git"

# Remove entire directory from tracking
git rm -r --cached <directory>
```
