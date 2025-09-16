# Submodule Best Practices

## Overview

This document outlines best practices for working with Git submodules in the Delta Data Platform project.

## Quick Reference

```bash
# Before EVERY commit to main repo
git submodule status --recursive  # Check for changes
git submodule foreach git status --short  # See what changed

# Fix common issues
git submodule foreach --recursive git reset --hard  # Reset all (loses changes!)
git submodule update --init --recursive  # Initialize and update
```

## Why These Practices Matter

Submodules can cause significant CI/CD failures if not managed properly:
- ❌ Uncommitted changes = failed builds
- ❌ Unpushed commits = broken clones for teammates  
- ❌ Detached HEAD = lost work
- ❌ Large files = slow operations

## The Golden Rules

### 1. Always Push Submodule Changes First

```bash
# WRONG ❌
cd ../..
git add apps/n8n
git commit -m "update n8n"
git push  # n8n commits not in remote!

# RIGHT ✅
cd apps/n8n
git push origin branch-name
cd ../..
git add apps/n8n
git commit -m "update n8n"
git push
```

### 2. Keep Submodules Clean

Local dev files should be in `.gitignore`:

```bash
# Check what's not ignored
cd apps/n8n
git status

# Add to .gitignore
echo "n8n_data/" >> .gitignore
echo ".env.local" >> .gitignore
```

### 3. Enable Pre-commit Hooks

```bash
# One-time setup
git config core.hooksPath .githooks
```

## Common Workflows

### After Cloning the Repo

```bash
git clone --recursive <repo-url>
# OR if already cloned:
git submodule update --init --recursive
```

### Updating a Submodule

```bash
cd apps/twenty
git checkout main
git pull origin main
cd ../..
git add apps/twenty
git commit -m "chore: update twenty to latest"
```

### Before Every Commit

```bash
# Run this check
git submodule status --recursive

# Look for:
# + prefix = uncommitted changes (fix required!)
# - prefix = not initialized (run init command)
# No prefix = clean ✅
```

## Troubleshooting

### "Submodule has uncommitted changes" Error

```bash
cd apps/affected-submodule
git status  # See what changed

# Option 1: Keep changes
git add .
git commit -m "your changes"
git push origin your-branch

# Option 2: Discard changes
git reset --hard
```

### "Detached HEAD state" Warning

```bash
cd apps/submodule
git checkout main  # Or appropriate branch
```

### CI Pipeline Failures

Our GitHub Actions workflow checks:
- ✅ All submodules initialized
- ✅ No uncommitted changes
- ✅ Commits exist in remote
- ✅ No files >100MB
- ✅ .gitmodules validity

## Emergency Reset

**⚠️ WARNING: Destroys all local changes!**

```bash
# Nuclear option - complete reset
git submodule deinit -f --all
git submodule update --init --recursive --force
```

## For CI/CD

The workflow (`.github/workflows/ci-submodules.yaml`) automatically:
- Validates submodules on every push to main/dev
- Checks for uncommitted changes
- Verifies commits are pushed to remotes
- Reports submodule updates in PRs
- Detects large files that should use Git LFS

## Team Rules

1. **Never commit with dirty submodules**
2. **Always push submodule commits before parent commits**
3. **Document submodule updates in PR descriptions**
4. **Use pre-commit hooks**
5. **Keep local dev files in .gitignore**
