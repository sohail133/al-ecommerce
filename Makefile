.PHONY: help build up down restart logs shell db-migrate db-rollback db-seed test staging production

# Default target
help:
	@echo "Available commands:"
	@echo "  make build          - Build Docker images"
	@echo "  make up             - Start development environment"
	@echo "  make down           - Stop all containers"
	@echo "  make restart        - Restart all containers"
	@echo "  make logs           - View logs"
	@echo "  make shell          - Open Rails console"
	@echo "  make db-migrate     - Run database migrations"
	@echo "  make db-rollback    - Rollback last migration"
	@echo "  make db-seed        - Seed database"
	@echo "  make test           - Run tests"
	@echo "  make staging        - Deploy to staging"
	@echo "  make production     - Deploy to production"

# Development
build:
	docker-compose build

up:
	docker-compose up -d
	@echo "✅ Development environment is running!"
	@echo "🌐 Visit http://localhost:3000"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

shell:
	docker-compose exec web bundle exec rails console

bash:
	docker-compose exec web bash

# Database
db-create:
	docker-compose exec web bundle exec rails db:create

db-migrate:
	docker-compose exec web bundle exec rails db:migrate

db-rollback:
	docker-compose exec web bundle exec rails db:rollback

db-seed:
	docker-compose exec web bundle exec rails db:seed

db-reset:
	docker-compose exec web bundle exec rails db:drop db:create db:migrate db:seed

# Testing
test:
	docker-compose exec web bundle exec rails test

test-system:
	docker-compose exec web bundle exec rails test:system

# Assets
assets-precompile:
	docker-compose exec web bundle exec rails assets:precompile

assets-clean:
	docker-compose exec web bundle exec rails assets:clean

# Staging
staging-build:
	docker-compose -f docker-compose.staging.yml build

staging-up:
	docker-compose -f docker-compose.staging.yml up -d

staging-down:
	docker-compose -f docker-compose.staging.yml down

staging-logs:
	docker-compose -f docker-compose.staging.yml logs -f

staging-deploy:
	./scripts/deploy-staging.sh

# Production
production-build:
	docker-compose -f docker-compose.production.yml build

production-up:
	docker-compose -f docker-compose.production.yml up -d

production-down:
	docker-compose -f docker-compose.production.yml down

production-logs:
	docker-compose -f docker-compose.production.yml logs -f

production-deploy:
	./scripts/deploy-production.sh

# SSL Setup
ssl-staging:
	./scripts/setup-ssl.sh staging.alecommerce.com admin@alecommerce.com staging

ssl-production:
	./scripts/setup-ssl.sh alecommerce.com admin@alecommerce.com production

# Backup
backup:
	docker-compose -f docker-compose.production.yml exec -T db pg_dump -U postgres al_ecommerce_production | gzip > backups/manual_backup_$(shell date +%Y%m%d_%H%M%S).sql.gz

# Clean up
clean:
	docker-compose down -v
	docker system prune -f

clean-all:
	docker-compose down -v --rmi all
	docker system prune -af --volumes

