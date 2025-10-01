# Makefile pour PHP Static Binaries Builder

.PHONY: help build test clean docker-build docker-test local-test

# Variables
PHP_VERSION ?= 8.2.14
BUILD_DIR ?= /tmp/php-build
DOCKER_IMAGE ?= php-static-builder

# Aide
help:
	@echo "PHP Static Binaries Builder"
	@echo ""
	@echo "Commandes disponibles:"
	@echo "  build          - Construire les binaires avec Docker"
	@echo "  test           - Exécuter tous les tests"
	@echo "  docker-build   - Construire l'image Docker"
	@echo "  docker-test    - Tester avec Docker"
	@echo "  local-test     - Tester localement (nécessite Docker)"
	@echo "  clean          - Nettoyer les fichiers temporaires"
	@echo "  help           - Afficher cette aide"
	@echo ""
	@echo "Variables:"
	@echo "  PHP_VERSION    - Version de PHP à compiler (défaut: 8.3.0)"
	@echo "  BUILD_DIR      - Répertoire de build (défaut: /tmp/php-build)"
	@echo "  DOCKER_IMAGE   - Nom de l'image Docker (défaut: php-static-builder)"

# Construction des binaires
build: docker-build
	@echo "Construction des binaires PHP statiques..."
	@docker run --rm -v $(PWD)/dist:/output $(DOCKER_IMAGE):latest

# Tests
test: docker-test
	@echo "Exécution des tests..."

# Construction de l'image Docker
docker-build:
	@echo "Construction de l'image Docker..."
	@docker build -t $(DOCKER_IMAGE):latest .

# Test avec Docker
docker-test:
	@echo "Test avec Docker..."
	@docker run --rm $(DOCKER_IMAGE):latest /tmp/scripts/test-build.sh

# Test local
local-test:
	@echo "Test local..."
	@./scripts/test-build.sh

# Nettoyage
clean:
	@echo "Nettoyage des fichiers temporaires..."
	@rm -rf dist/
	@rm -rf /tmp/php-build/
	@rm -rf /tmp/php-static/
	@docker rmi $(DOCKER_IMAGE):latest 2>/dev/null || true

# Installation des dépendances (pour développement)
install-deps:
	@echo "Installation des dépendances de développement..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "Docker n'est pas installé. Veuillez l'installer d'abord."; \
		exit 1; \
	fi
	@if ! docker version >/dev/null 2>&1; then \
		echo "Docker Buildx n'est pas disponible. Veuillez l'activer."; \
		exit 1; \
	fi

# Validation de l'environnement
validate-env:
	@echo "Validation de l'environnement..."
	@command -v docker >/dev/null 2>&1 || (echo "Docker requis" && exit 1)
	@command -v git >/dev/null 2>&1 || (echo "Git requis" && exit 1)
	@echo "Environnement validé ✓"

# Construction pour toutes les architectures
build-all: validate-env
	@echo "Construction pour toutes les architectures..."
	@make clean
	@make docker-build
	@echo "Construction x86_64..."
	@docker run --rm --platform linux/amd64 -v $(PWD)/dist:/output $(DOCKER_IMAGE):latest
	@echo "Construction aarch64..."
	@docker run --rm --platform linux/arm64 -v $(PWD)/dist:/output $(DOCKER_IMAGE):latest
	@echo "Construction terminée ✓"

# Test des binaires construits
test-binaries:
	@echo "Test des binaires construits..."
	@if [ -f "dist/php-static-x86_64-linux.tar.gz" ]; then \
		echo "Test du binaire x86_64..."; \
		cd dist && tar -xzf php-static-x86_64-linux.tar.gz; \
		./tests/validate-binary.sh ./php-static; \
		rm -rf php-static; \
	fi
	@if [ -f "dist/php-static-aarch64-linux.tar.gz" ]; then \
		echo "Test du binaire aarch64..."; \
		cd dist && tar -xzf php-static-aarch64-linux.tar.gz; \
		./tests/validate-binary.sh ./php-static; \
		rm -rf php-static; \
	fi

# Développement
dev-setup: install-deps validate-env
	@echo "Configuration de l'environnement de développement..."
	@echo "Environnement prêt pour le développement ✓"

# Documentation
docs:
	@echo "Génération de la documentation..."
	@echo "Documentation disponible dans docs/"

# Release (simulation locale)
release-test:
	@echo "Test de release local..."
	@make clean
	@make build-all
	@make test-binaries
	@echo "Release test terminé ✓"
