#!/bin/bash

# Script to set up Rails encrypted credentials for staging and production

set -e

echo "🔐 Rails Encrypted Credentials Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if development credentials exist
if [ ! -f "config/master.key" ]; then
    echo "⚠️  Development credentials not found"
    echo "Creating development credentials first..."
    EDITOR=nano rails credentials:edit
fi

echo "✅ Development master key: $(cat config/master.key)"
echo ""

# Create staging credentials
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Setting up STAGING credentials"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "config/credentials/staging.key" ]; then
    echo "Creating staging credentials..."
    rails credentials:edit --environment staging
fi

STAGING_KEY=$(cat config/credentials/staging.key)
echo "✅ Staging key created: $STAGING_KEY"
echo ""

# Generate staging credentials template
cat > /tmp/staging_credentials_template.yml << 'EOF'
# Rails Secret Key Base
secret_key_base: GENERATED_SECRET_KEY_BASE

# Database Configuration
database:
  username: staging_user
  password: GENERATED_DB_PASSWORD
  host: db
  port: 5432
  database: al_ecommerce_staging

# Redis Configuration  
redis:
  url: redis://:GENERATED_REDIS_PASSWORD@redis:6379/0
  password: GENERATED_REDIS_PASSWORD

# Email Configuration (SMTP)
smtp:
  address: smtp.gmail.com
  port: 587
  domain: staging.alecommerce.com
  username: your_email@gmail.com
  password: your_gmail_app_password
  authentication: plain
  enable_starttls_auto: true

# Domain
domain: staging.alecommerce.com

# Payment Gateway (Optional)
# stripe:
#   publishable_key: pk_test_xxx
#   secret_key: sk_test_xxx

# Cloud Storage (Optional)
# aws:
#   access_key_id: your_key
#   secret_access_key: your_secret
#   region: us-east-1
#   bucket: alecommerce-staging
EOF

# Generate actual values
SECRET_KEY=$(openssl rand -hex 64)
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Replace placeholders
sed -i "s/GENERATED_SECRET_KEY_BASE/$SECRET_KEY/" /tmp/staging_credentials_template.yml
sed -i "s/GENERATED_DB_PASSWORD/$DB_PASSWORD/" /tmp/staging_credentials_template.yml
sed -i "s/GENERATED_REDIS_PASSWORD/$REDIS_PASSWORD/g" /tmp/staging_credentials_template.yml

echo "📄 Staging credentials template created at: /tmp/staging_credentials_template.yml"
echo ""
echo "To edit staging credentials, run:"
echo "  EDITOR=nano rails credentials:edit --environment staging"
echo ""
echo "Then copy the content from: /tmp/staging_credentials_template.yml"
echo ""

# Create production credentials
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Setting up PRODUCTION credentials"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "config/credentials/production.key" ]; then
    echo "Creating production credentials..."
    rails credentials:edit --environment production
fi

PRODUCTION_KEY=$(cat config/credentials/production.key)
echo "✅ Production key created: $PRODUCTION_KEY"
echo ""

# Generate production credentials template
cat > /tmp/production_credentials_template.yml << 'EOF'
# Rails Secret Key Base
secret_key_base: GENERATED_SECRET_KEY_BASE

# Database Configuration
database:
  username: prod_user
  password: GENERATED_DB_PASSWORD
  host: db
  port: 5432
  database: al_ecommerce_production

# Redis Configuration
redis:
  url: redis://:GENERATED_REDIS_PASSWORD@redis:6379/0
  password: GENERATED_REDIS_PASSWORD

# Email Configuration (SMTP)
smtp:
  address: smtp.gmail.com
  port: 587
  domain: alecommerce.com
  username: your_email@gmail.com
  password: your_gmail_app_password
  authentication: plain
  enable_starttls_auto: true

# Domain
domain: alecommerce.com

# Payment Gateway (Update with production keys)
# stripe:
#   publishable_key: pk_live_xxx
#   secret_key: sk_live_xxx

# Cloud Storage (REQUIRED for production)
# aws:
#   access_key_id: your_key
#   secret_access_key: your_secret
#   region: us-east-1
#   bucket: alecommerce-production
EOF

# Generate different production values
SECRET_KEY=$(openssl rand -hex 64)
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Replace placeholders
sed -i "s/GENERATED_SECRET_KEY_BASE/$SECRET_KEY/" /tmp/production_credentials_template.yml
sed -i "s/GENERATED_DB_PASSWORD/$DB_PASSWORD/" /tmp/production_credentials_template.yml
sed -i "s/GENERATED_REDIS_PASSWORD/$REDIS_PASSWORD/g" /tmp/production_credentials_template.yml

echo "📄 Production credentials template created at: /tmp/production_credentials_template.yml"
echo ""
echo "To edit production credentials, run:"
echo "  EDITOR=nano rails credentials:edit --environment production"
echo ""
echo "Then copy the content from: /tmp/production_credentials_template.yml"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CREDENTIALS KEYS GENERATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Your credential keys:"
echo ""
echo "Development: $(cat config/master.key)"
echo "Staging:     $STAGING_KEY"
echo "Production:  $PRODUCTION_KEY"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Edit staging credentials:"
echo "   EDITOR=nano rails credentials:edit --environment staging"
echo "   Copy content from: /tmp/staging_credentials_template.yml"
echo ""
echo "2. Edit production credentials:"
echo "   EDITOR=nano rails credentials:edit --environment production"
echo "   Copy content from: /tmp/production_credentials_template.yml"
echo ""
echo "3. For Docker, create these files with ONLY the master keys:"
echo ""
echo "   # Create .env.staging"
echo "   echo \"RAILS_MASTER_KEY=$STAGING_KEY\" > .env.staging"
echo ""
echo "   # Create .env.production"
echo "   echo \"RAILS_MASTER_KEY=$PRODUCTION_KEY\" > .env.production"
echo ""
echo "4. Keep these key files secure and never commit to git!"
echo ""
echo "🔒 Files are already in .gitignore:"
echo "   - config/master.key"
echo "   - config/credentials/*.key"
echo "   - .env.staging"
echo "   - .env.production"
echo ""

