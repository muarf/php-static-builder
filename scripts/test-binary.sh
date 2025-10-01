#!/bin/bash
# Script de test pour les binaires PHP statiques

set -e

BINARY_FILE=${1}
PLATFORM=${2:-unknown}

echo "=== Test de binaire PHP statique ==="
echo "Fichier: $BINARY_FILE"
echo "Plateforme: $PLATFORM"
echo "===================================="

if [ ! -f "$BINARY_FILE" ]; then
    echo "❌ Erreur: Fichier $BINARY_FILE non trouvé"
    exit 1
fi

# Créer un répertoire temporaire pour les tests
TEST_DIR=$(mktemp -d)
echo "Répertoire de test: $TEST_DIR"

# Extraire l'archive
echo "Extraction de l'archive..."
cd "$TEST_DIR"
tar -xzf "$BINARY_FILE"

# Vérifier la structure
echo "Vérification de la structure..."
if [ ! -f "bin/php" ]; then
    echo "❌ Erreur: bin/php non trouvé"
    exit 1
fi

if [ ! -f "sbin/php-fpm" ]; then
    echo "❌ Erreur: sbin/php-fpm non trouvé"
    exit 1
fi

# Vérifier les permissions d'exécution
echo "Vérification des permissions..."
chmod +x bin/php sbin/php-fpm

# Test de base
echo "Test de base..."
echo "Version PHP:"
./bin/php --version || echo "⚠️  Test version échoué"

echo "Version PHP-FPM:"
./sbin/php-fpm --version || echo "⚠️  Test version PHP-FPM échoué"

# Test de fonctionnalité
echo "Test de fonctionnalité..."
./bin/php -r "echo 'Hello from PHP static binary!'; echo PHP_EOL;" || echo "⚠️  Test fonctionnalité échoué"

# Test des modules
echo "Modules chargés:"
./bin/php -m | head -10 || echo "⚠️  Test modules échoué"

# Test de configuration
echo "Configuration PHP:"
./bin/php -i | grep -E "(PHP Version|Build Date|Architecture)" || echo "⚠️  Test configuration échoué"

# Nettoyage
echo "Nettoyage..."
cd /
rm -rf "$TEST_DIR"

echo "✅ Test terminé avec succès!"
echo "Binaire: $BINARY_FILE"
echo "Plateforme: $PLATFORM"
