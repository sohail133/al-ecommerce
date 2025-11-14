# Use Ruby 3.3.0 as base image
FROM ruby:3.3.0-slim

# Build argument for Rails environment (defaults to production)
ARG RAILS_ENV=production

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    libjemalloc2 \
    libsqlite3-0 \
    nodejs \
    npm \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy package files and install node modules
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy application code
COPY . .

# Precompile assets using the build argument
# Create a dummy master key for asset precompilation
RUN bundle exec rails assets:precompile

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /app

USER rails:rails

# Expose port 3000
EXPOSE 3000

# Set environment variables
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true"

# Use jemalloc for better memory management
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

# Start the server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
