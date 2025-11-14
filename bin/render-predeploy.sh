#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "==> Checking built assets..."
ls -la app/assets/builds/

echo "==> Running database migrations..."
bundle exec rails db:migrate

echo "==> Precompiling static assets (copying built JS/CSS to public)..."
# Skip CSS/JS build since already done in Docker
bundle exec rails assets:precompile SKIP_YARN_BUILD=true

echo "==> Checking public assets..."
ls -la public/assets/ || echo "No public/assets directory"

echo "==> Pre-deploy completed successfully!"

