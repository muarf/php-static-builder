#!/bin/bash

set -e

echo "=== PHP Binary Validation Tests ==="

BINARY_DIR="${1:-./php-static}"
PHP_BIN="${BINARY_DIR}/bin/php"
FPM_BIN="${BINARY_DIR}/bin/php-fpm"

# Vérification de l'existence des binaires
echo "Checking binary existence..."
if [ ! -f "${PHP_BIN}" ]; then
    echo "ERROR: PHP binary not found at ${PHP_BIN}"
    exit 1
fi

if [ ! -f "${FPM_BIN}" ]; then
    echo "ERROR: PHP-FPM binary not found at ${FPM_BIN}"
    exit 1
fi

echo "✓ Binaries found"

# Test des versions
echo "Testing PHP version..."
PHP_VERSION=$(${PHP_BIN} --version | head -1)
echo "PHP Version: ${PHP_VERSION}"

echo "Testing PHP-FPM version..."
FPM_VERSION=$(${FPM_BIN} --version | head -1)
echo "PHP-FPM Version: ${FPM_VERSION}"

# Test des extensions
echo "Testing PHP extensions..."
${PHP_BIN} -m > /tmp/php_modules.txt
echo "Loaded modules:"
cat /tmp/php_modules.txt

# Vérification des extensions essentielles
ESSENTIAL_MODULES=("core" "json" "hash" "session" "filter" "tokenizer" "opcache" "fileinfo" "mbstring" "ctype" "pdo" "sqlite3" "zip" "gd" "curl" "openssl")

echo "Checking essential modules..."
for module in "${ESSENTIAL_MODULES[@]}"; do
    if grep -q "^${module}$" /tmp/php_modules.txt; then
        echo "✓ ${module} loaded"
    else
        echo "✗ ${module} missing"
        exit 1
    fi
done

# Test de fonctionnement basique
echo "Testing basic PHP functionality..."
${PHP_BIN} -r "echo 'PHP is working: ' . phpversion() . PHP_EOL;"

# Test de JSON
echo "Testing JSON functionality..."
${PHP_BIN} -r "echo 'JSON test: ' . json_encode(['test' => 'success']) . PHP_EOL;"

# Test de base64
echo "Testing base64 functionality..."
${PHP_BIN} -r "echo 'Base64 test: ' . base64_encode('hello world') . PHP_EOL;"

# Test de hash
echo "Testing hash functionality..."
${PHP_BIN} -r "echo 'Hash test: ' . hash('sha256', 'test') . PHP_EOL;"

# Test de cURL
echo "Testing cURL functionality..."
${PHP_BIN} -r "echo 'cURL test: ' . (extension_loaded('curl') ? 'loaded' : 'not loaded') . PHP_EOL;"

# Test de GD
echo "Testing GD functionality..."
${PHP_BIN} -r "echo 'GD test: ' . (extension_loaded('gd') ? 'loaded' : 'not loaded') . PHP_EOL;"

# Test de SQLite
echo "Testing SQLite functionality..."
${PHP_BIN} -r "
try {
    \$pdo = new PDO('sqlite::memory:');
    echo 'SQLite test: success' . PHP_EOL;
} catch (Exception \$e) {
    echo 'SQLite test: failed - ' . \$e->getMessage() . PHP_EOL;
    exit(1);
}
"

# Test de ZIP
echo "Testing ZIP functionality..."
${PHP_BIN} -r "echo 'ZIP test: ' . (extension_loaded('zip') ? 'loaded' : 'not loaded') . PHP_EOL;"

# Test de taille des binaires
echo "Checking binary sizes..."
PHP_SIZE=$(du -h "${PHP_BIN}" | cut -f1)
FPM_SIZE=$(du -h "${FPM_BIN}" | cut -f1)
echo "PHP binary size: ${PHP_SIZE}"
echo "PHP-FPM binary size: ${FPM_SIZE}"

# Test de dépendances
echo "Checking binary dependencies..."
if command -v ldd &> /dev/null; then
    echo "PHP dependencies:"
    ldd "${PHP_BIN}" || echo "Static binary (no dependencies)"
    
    echo "PHP-FPM dependencies:"
    ldd "${FPM_BIN}" || echo "Static binary (no dependencies)"
else
    echo "ldd not available, skipping dependency check"
fi

# Test de PHP-FPM (configuration)
echo "Testing PHP-FPM configuration..."
${FPM_BIN} --test

echo "=== All validation tests passed! ==="
