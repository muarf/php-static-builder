#!/bin/bash
# Script de test pour binaires macOS avec Docker

set -e

BINARY_FILE=${1}

echo "=== Test de binaire macOS avec Docker ==="
echo "Fichier: $BINARY_FILE"
echo "========================================"

if [ ! -f "$BINARY_FILE" ]; then
    echo "❌ Erreur: Fichier $BINARY_FILE non trouvé"
    exit 1
fi

# Créer un Dockerfile temporaire pour tester le binaire macOS
cat > Dockerfile.test << 'EOF'
FROM ubuntu:22.04

# Installer les dépendances pour simuler un environnement macOS
RUN apt-get update && apt-get install -y \
    qemu-user-static \
    binfmt-support \
    && rm -rf /var/lib/apt/lists/*

# Copier le binaire
COPY test-binary.tar.gz /tmp/
WORKDIR /tmp

# Extraire et tester
RUN tar -xzf test-binary.tar.gz && \
    chmod +x bin/php sbin/php-fpm && \
    echo "Testing macOS binary in Linux container..." && \
    ./bin/php --version && \
    ./sbin/php-fpm --version && \
    ./bin/php -r "echo 'Hello from PHP static binary!'; echo PHP_EOL;" && \
    ./bin/php -m | head -5 && \
    echo "✅ macOS binary test completed successfully!"
EOF

# Copier le binaire pour le test
cp "$BINARY_FILE" test-binary.tar.gz

echo "Construction de l'image Docker de test..."
docker build -f Dockerfile.test -t php-macos-test .

echo "Exécution du test..."
docker run --rm php-macos-test

# Nettoyage
rm -f Dockerfile.test test-binary.tar.gz
docker rmi php-macos-test

echo "✅ Test Docker terminé avec succès!"
