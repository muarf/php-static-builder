#!/bin/bash
# Script pour tester les binaires localement

set -e

BINARY_TYPE=${1:-linux}
ARCH=${2:-amd64}

echo "=== Test de binaire local ==="
echo "Type: $BINARY_TYPE"
echo "Architecture: $ARCH"
echo "============================="

# Déterminer le chemin du binaire
if [ "$BINARY_TYPE" = "macos" ]; then
    BINARY_PATH="dist/php-static-${ARCH}-macos.tar.gz"
    echo "🐳 Test macOS avec émulation Docker..."
    ./scripts/test-macos-binary.sh "$ARCH" "$BINARY_PATH"
elif [ "$BINARY_TYPE" = "linux" ]; then
    BINARY_PATH="dist/php-static-${ARCH}-linux.tar.gz"
    echo "🐧 Test Linux natif..."
    
    if [ ! -f "$BINARY_PATH" ]; then
        echo "❌ Binaire non trouvé: $BINARY_PATH"
        exit 1
    fi
    
    # Extraire et tester
    cd dist
    tar -xzf "php-static-${ARCH}-linux.tar.gz"
    
    echo "📋 Test du binaire Linux..."
    ./bin/php --version
    ./sbin/php-fpm --version
    ./bin/php -r "echo 'Hello from PHP static binary on Linux!'; echo PHP_EOL;"
    ./bin/php -m | head -10
    
    echo "✅ Test Linux terminé!"
else
    echo "❌ Type de binaire non supporté: $BINARY_TYPE"
    echo "Usage: $0 [linux|macos] [amd64|arm64]"
    exit 1
fi
