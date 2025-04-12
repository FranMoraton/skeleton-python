.PHONY: all help init clean build start stop logs bash validate lint lint-fix format format-fix type-check test migrations

UID=$(shell id -u)
GID=$(shell id -g)
DOCKER_PYTHON_SERVICE=python

all: help

help: ## Display the available commands in this Makefile
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                           ${CYAN}.:${RESET} AVAILABLE COMMANDS ${CYAN}:.${RESET}                           ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${COMMAND_COLOR}%-40s${RESET} ${HELP_COLOR}%s${RESET}\n", $$1, $$2}'
	@echo ""

init: clean build start install-hooks ## Initialize the project (clean, build, start, install hooks)

install-hooks: ## Install Git hooks
	cp hooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
	
clean: ## Remove Docker containers and volumes
	docker compose down -v

build: ## Build Docker images
	docker compose build

start: ## Start Docker services
	docker compose up -d

stop: ## Stop Docker services
	docker compose stop

logs: ## Display logs of the Python service
	docker compose logs -f ${DOCKER_PYTHON_SERVICE}

bash: ## Access the Python container shell
	docker compose exec -it -u ${UID}:${GID} ${DOCKER_PYTHON_SERVICE} sh

# VALIDATION COMMANDS --------------------------------------------------------------------------------------------------
validate: lint type-check test ## Run all validation tools

lint: ## Run ruff to check code style
	docker compose run --no-deps --rm ${DOCKER_PYTHON_SERVICE} ruff check

lint-fix: ## Run ruff to fix code style issues
	docker compose run --no-deps --rm ${DOCKER_PYTHON_SERVICE} ruff check --fix

type-check: ## Run mypy to check type annotations
	docker compose run --no-deps --rm ${DOCKER_PYTHON_SERVICE} mypy .

test: ## Run pytest to execute tests
	docker compose run --no-deps --rm ${DOCKER_PYTHON_SERVICE} pytest

# DATABASE COMMANDS ----------------------------------------------------------------------------------------------------
migrations: ## Run database migrations
	docker compose run --rm ${DOCKER_PYTHON_SERVICE} sh -c 'while ! nc -z db 5432; do echo "Waiting for DB service"; sleep 3; done;'
	docker compose run --rm ${DOCKER_PYTHON_SERVICE} alembic upgrade head