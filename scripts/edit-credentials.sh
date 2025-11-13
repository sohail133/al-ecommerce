#!/bin/bash

# Quick script to edit credentials for any environment

ENVIRONMENT=${1:-development}

echo "🔐 Editing ${ENVIRONMENT} credentials..."
echo ""

if [ "$ENVIRONMENT" = "development" ]; then
    echo "Opening development credentials..."
    EDITOR=nano rails credentials:edit
else
    echo "Opening ${ENVIRONMENT} credentials..."
    EDITOR=nano rails credentials:edit --environment ${ENVIRONMENT}
fi

echo ""
echo "✅ Credentials saved!"
echo ""
echo "To view (without editing):"
if [ "$ENVIRONMENT" = "development" ]; then
    echo "  rails credentials:show"
else
    echo "  rails credentials:show --environment ${ENVIRONMENT}"
fi

