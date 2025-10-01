#!/bin/bash

set -e

echo "=== PHP Static Binary Test Script ==="

# Configuration
PHP_VERSION=${PHP_VERSION:-"8.2.14"}
BUILD_DIR="/tmp/php-test-build"

# Nettoyage
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

echo "Testing PHP ${PHP_VERSION} build process..."

# Test de compilation locale (nécessite Docker)
if command -v docker &> /dev/null; then
    echo "Docker found. Testing build process..."
    
    # Build du container de test
    docker build -t php-static-test .
    
    # Test pour x86_64
    echo "Testing x86_64 build..."
    docker run --rm -v ${BUILD_DIR}:/output php-static-test \
        bash -c "
            export BUILD_ARCH=x86_64
            export TARGET_ARCH=x86_64-linux-gnu
            /tmp/scripts/build-php.sh && 
            cp /tmp/php-static.tar.gz /output/php-static-x86_64-linux.tar.gz
        "
    
    # Test du binaire x86_64
    if [ -f "${BUILD_DIR}/php-static-x86_64-linux.tar.gz" ]; then
        echo "x86_64 build successful!"
        cd ${BUILD_DIR}
        tar -xzf php-static-x86_64-linux.tar.gz
        ./bin/php --version
        ./bin/php-fpm --version
        echo "Binary size: $(du -h ./bin/php | cut -f1)"
        echo "FPM binary size: $(du -h ./bin/php-fpm | cut -f1)"
    else
        echo "x86_64 build failed!"
        exit 1
    fi
    
    # Test pour aarch64 (si supporté)
    if docker buildx ls | grep -q "linux/arm64"; then
        echo "Testing aarch64 build..."
        docker run --rm --platform linux/arm64 -v ${BUILD_DIR}:/output php-static-test \
            bash -c "
                export BUILD_ARCH=aarch64
                export TARGET_ARCH=aarch64-linux-gnu
                /tmp/scripts/build-php.sh && 
                cp /tmp/php-static.tar.gz /output/php-static-aarch64-linux.tar.gz
            "
        
        if [ -f "${BUILD_DIR}/php-static-aarch64-linux.tar.gz" ]; then
            echo "aarch64 build successful!"
        else
            echo "aarch64 build failed!"
        fi
    else
        echo "aarch64 build skipped (platform not supported)"
    fi
    
else
    echo "Docker not found. Skipping build tests."
    echo "To test locally, install Docker and run:"
    echo "  docker build -t php-static-test ."
    echo "  docker run --rm -v \$(pwd)/test-output:/output php-static-test"
fi

echo "=== Test completed ==="
