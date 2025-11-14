# Configure Propshaft asset pipeline for Rails 8
Rails.application.configure do
  # Add the builds directory to Propshaft's load path
  # This is where esbuild and tailwind output compiled assets
  config.assets.paths << Rails.root.join("app/assets/builds")
end

