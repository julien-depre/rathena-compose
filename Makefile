.PHONY: build up run down logs help init extract-sql clean reset init-env init-sql-override init-db

# Default target
help:
	@echo "Available commands:"
	@printf "  %-28s %s\n" "make init"              "Initialize project (.env + build + extract SQL + override)"
	@printf "  %-28s %s\n" "make reset"             "Clean everything and reinitialize (clean + down + init)"
	@printf "  %-28s %s\n" "make init-env"          "Generate .env with defaults if missing"
	@printf "  %-28s %s\n" "make build"             "Pull Docker images from the registry"
	@printf "  %-28s %s\n" "make extract-sql"       "Extract SQL files from rAthena image"
	@printf "  %-28s %s\n" "make init-sql-override" "Create override to update default"
	@printf "  %-28s %s\n" "make init-db"           "Initialize database with SQL files"
	@printf "  %-28s %s\n" "make up"                "Start the rAthena services (detached)"
	@printf "  %-28s %s\n" "make run"               "Start services and show logs (Ctrl+C to stop)"
	@printf "  %-28s %s\n" "make down"              "Stop the rAthena services and remove volumes"
	@printf "  %-28s %s\n" "make logs"              "Show logs from all services"
	@printf "  %-28s %s\n" "make follow"            "Show logs and follow (streaming)"
	@printf "  %-28s %s\n" "make clean"             "Remove generated files (logs, SQL)"
	@printf "  %-28s %s\n" "make help"              "Show this help message"

# Initialize project: build images and extract SQL files
init: init-env build extract-sql init-sql-override init-db up init-fluxcp
	@echo "Initialization complete! rAthena services are up."

# Reset everything: clean, stop services, and reinitialize
reset: clean init
	@echo "Reset complete! Run 'make up' to start fresh services."

# Initialize .env with defaults if missing
init-env:
	@echo "Initializing .env file..."
	@./scripts/init-env.sh

# Pull Docker images from registry
build:
	@echo "Pulling Docker images from registry..."
	docker compose pull

# Extract SQL files from the built image
extract-sql:
	@echo "Extracting SQL initialization files..."
	@./scripts/extract-sql.sh

# Create final override SQL to update default account based on .env
init-sql-override:
	@echo "Generating SQL override ..."
	@./scripts/init-sql-override.sh

# Initialize database with SQL files
init-db:
	@echo "Initializing database..."
	@./scripts/init-db.sh

# Initialize FluxCP database
init-fluxcp:
	@echo "Initializing FluxCP database..."
	@./scripts/init-fluxcp.sh

# Start services (detached)
up:
	@echo "Starting rAthena services..."
	docker compose up --detach

# Start services (foreground) and show logs
run:
	@echo "Starting rAthena services (foreground)..."
	docker compose up

# Stop services
down:
	@echo "Stopping rAthena services..."
	docker compose down --remove-orphans

# Show logs
logs:
	@echo "Showing logs from all services..."
	docker compose logs --tail=100
# Show logs

follow:
	@echo "Showing logs from all services..."
	docker compose logs --follow --tail=10

# Clean generated files, and containers/volumes
clean: down
	@echo "Cleaning generated files..."
	@./scripts/clean.sh