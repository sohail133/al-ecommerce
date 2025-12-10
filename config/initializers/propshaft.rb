# Configure Propshaft asset pipeline for Rails 8
# Propshaft automatically includes app/assets/builds if it exists
# Just ensure it's in the load path
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds") if Rails.root.join("app/assets/builds").exist?

