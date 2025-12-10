#!/usr/bin/env bash
# Exit on error
set -o errexit

# Print environment info
echo "==> Environment Information"
echo "RAILS_ENV: ${RAILS_ENV}"
echo "RAILS_MASTER_KEY present: $([ -n "$RAILS_MASTER_KEY" ] && echo 'YES' || echo 'NO')"

echo "==> Checking built assets..."
ls -la app/assets/builds/

echo "==> Running database migrations..."
RAILS_ENV=${RAILS_ENV:-production} bundle exec rails db:migrate

echo "==> Precompiling static assets (copying built JS/CSS to public)..."
# Skip CSS/JS build since already done in Docker
# Explicitly set RAILS_ENV to ensure correct environment configuration
RAILS_ENV=${RAILS_ENV:-production} bundle exec rails assets:precompile

echo "==> Checking public assets..."
ls -la public/assets/ || echo "No public/assets directory"

echo "==> Pre-deploy completed successfully!"

