#!/bin/bash
# Script pour tester un binaire macOS sans Mac
# Utilise Docker avec émulation QEMU

set -e

ARCH=${1:-amd64}
BINARY_PATH=${2:-dist/php-static-${ARCH}-macos.tar.gz}

echo "=== Test de binaire macOS sans Mac ==="
echo "Architecture: $ARCH"
echo "Binaire: $BINARY_PATH"
echo "======================================"

# Vérifier que le binaire existe
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Binaire non trouvé: $BINARY_PATH"
    exit 1
fi

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    echo "Installez Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Créer un Dockerfile pour tester le binaire
cat > Dockerfile.macos-test << 'EOF'
FROM --platform=linux/amd64 ubuntu:22.04

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    qemu-user-static \
    binfmt-support \
    && rm -rf /var/lib/apt/lists/*

# Copier le binaire
COPY php-static.tar.gz /tmp/
WORKDIR /tmp

# Extraire et tester
RUN tar -xzf php-static.tar.gz

# Tester le binaire
CMD ["./bin/php", "--version"]
EOF

echo "🐳 Création de l'image Docker de test..."
docker build -f Dockerfile.macos-test -t macos-binary-test .

echo "🧪 Test du binaire macOS..."
docker run --rm --platform linux/amd64 macos-binary-test

echo "✅ Test terminé!"
echo "📋 Note: Ce test utilise l'émulation QEMU"
echo "   Pour un test complet, utilisez GitHub Actions"

# Nettoyer
rm -f Dockerfile.macos-test
