#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Building JavaScript assets with esbuild..."
npm run build

echo "Building CSS assets with Tailwind..."
npm run build:css

echo "Running database migrations..."
bundle exec rails db:migrate

echo "Precompiling static assets..."
bundle exec rails assets:precompile

echo "Pre-deploy completed successfully!"

