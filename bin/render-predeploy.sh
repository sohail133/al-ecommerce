#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Running database migrations..."
bundle exec rails db:migrate

echo "Precompiling static assets (copying built JS/CSS to public)..."
bundle exec rails assets:precompile

echo "Pre-deploy completed successfully!"

