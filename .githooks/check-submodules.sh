#!/bin/bash

# Pre-commit hook to check submodule status
# Ensures submodules are clean and properly initialized

set -e

echo "🔍 Checking submodule status..."

# Check if any submodules have uncommitted changes
SUBMODULE_STATUS=$(git submodule status --recursive)

# Check for modified submodules (indicated by + prefix)
if echo "$SUBMODULE_STATUS" | grep -q '^+'; then
    echo "❌ Error: Submodules have uncommitted changes!"
    echo "The following submodules have modifications:"
    echo "$SUBMODULE_STATUS" | grep '^+' | awk '{print "  - " $2}'
    echo ""
    echo "Please either:"
    echo "  1. Commit the changes within the submodule(s)"
    echo "  2. Reset the submodule(s) to a clean state"
    echo ""
    echo "To reset all submodules:"
    echo "  git submodule foreach --recursive git reset --hard"
    echo ""
    exit 1
fi

# Check for uninitialized submodules (indicated by - prefix)
if echo "$SUBMODULE_STATUS" | grep -q '^-'; then
    echo "⚠️  Warning: Some submodules are not initialized!"
    echo "The following submodules need initialization:"
    echo "$SUBMODULE_STATUS" | grep '^-' | awk '{print "  - " $2}'
    echo ""
    echo "To initialize them, run:"
    echo "  git submodule update --init --recursive"
    echo ""
    # This is a warning, not an error - allow commit to proceed
fi

echo "✅ Submodule check passed!"
