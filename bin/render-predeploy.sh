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
# Manually invoke Propshaft without triggering css:build and javascript:build
RAILS_ENV=${RAILS_ENV:-production} bundle exec rails runner '
  require "propshaft/assembly"
  assembly = Rails.application.assets
  manifest = {}
  
  # Create public/assets directory
  FileUtils.mkdir_p(Rails.root.join("public/assets"))
  
  # Copy and digest assets
  assembly.load_path.assets.each do |asset|
    digested_path = asset.digested_path
    output_path = Rails.root.join("public/assets", digested_path)
    FileUtils.mkdir_p(output_path.dirname)
    FileUtils.cp(asset.path, output_path)
    manifest[asset.logical_path.to_s] = digested_path.to_s
    puts "  ✓ #{asset.logical_path} -> #{digested_path}"
  end
  
  # Write manifest
  File.write(Rails.root.join("public/assets/.manifest.json"), manifest.to_json)
  puts "Assets compiled: #{manifest.size} files"
'

echo "==> Checking public assets..."
ls -la public/assets/ || echo "No public/assets directory"

echo "==> Pre-deploy completed successfully!"

