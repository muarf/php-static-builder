#!/bin/bash
# Script de build multi-plateforme pour PHP statique

set -e

# Configuration
PHP_VERSION=${PHP_VERSION:-8.2.14}
BUILD_DIR=${BUILD_DIR:-/tmp/php-build}
INSTALL_DIR=${INSTALL_DIR:-/tmp/php-static}

# Détection de la plateforme
PLATFORM=${TARGET_PLATFORM:-linux/amd64}
BUILD_ARCH=$(echo $PLATFORM | cut -d'/' -f2)

echo "=== PHP Static Binary Builder (Multi-Platform) ==="
echo "PHP Version: $PHP_VERSION"
echo "Target Platform: $PLATFORM"
echo "Build Architecture: $BUILD_ARCH"
echo "=================================================="

# Configuration selon l'architecture
case $BUILD_ARCH in
    "amd64")
        TARGET_ARCH="x86_64-linux-gnu"
        STRIP="strip"
        ;;
    "arm64")
        TARGET_ARCH="aarch64-linux-gnu"
        STRIP="aarch64-linux-gnu-strip"
        ;;
    *)
        echo "Architecture non supportée: $BUILD_ARCH"
        exit 1
        ;;
esac

# Téléchargement de PHP
echo "Downloading PHP $PHP_VERSION..."
cd $BUILD_DIR
if [ ! -f "php-${PHP_VERSION}.tar.gz" ]; then
    wget -q "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz"
fi

# Extraction
echo "Extracting PHP source..."
tar -xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# Configuration de la compilation
echo "Configuring PHP build..."

# Patch pour corriger l'erreur struct sigaction
echo "Applying sigaction patch..."
sed -i '1i#include <signal.h>' /tmp/php-build/php-${PHP_VERSION}/Zend/zend_globals.h

# Configuration des options de cross-compilation
CROSS_COMPILE_OPTS=""
if [ "${BUILD_ARCH}" = "arm64" ]; then
    CROSS_COMPILE_OPTS="--host=aarch64-linux-gnu --target=aarch64-linux-gnu"
    export CC=aarch64-linux-gnu-gcc
    export CXX=aarch64-linux-gnu-g++
    export AR=aarch64-linux-gnu-ar
    export RANLIB=aarch64-linux-gnu-ranlib
    export STRIP=aarch64-linux-gnu-strip
    export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
fi

./configure \
    --prefix=${INSTALL_DIR} \
    ${CROSS_COMPILE_OPTS} \
    --disable-all \
    --enable-cli \
    --enable-fpm \
    --enable-static \
    --disable-shared \
    --with-config-file-path=${INSTALL_DIR}/etc \
    --with-config-file-scan-dir=${INSTALL_DIR}/etc/conf.d \
    --enable-json \
    --enable-hash \
    --enable-session \
    --enable-sqlite3 \
    --enable-zip \
    --enable-curl \
    --enable-openssl \
    --enable-readline \
    --enable-libxml \
    --enable-phar \
    --with-libxml \
    --with-zlib \
    --enable-zts=no \
    --disable-debug \
    --disable-rpath \
    --disable-static \
    --enable-shared=no \
    --with-pic \
    --disable-ipv6 \
    --without-pear \
    --without-iconv \
    --without-gettext \
    --disable-cgi \
    --disable-phpdbg \
    --enable-embed=no \
    --disable-zend-signals \
    --enable-zend-max-execution-timers \
    CFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1 -D_GNU_SOURCE" \
    CXXFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden -D_GNU_SOURCE" \
    LDFLAGS="-Wl,--gc-sections -Wl,--strip-all -static-libgcc -static-libstdc++"

# Compilation
echo "Building PHP..."
make -j$(nproc)

# Installation
echo "Installing PHP..."
make install

# Optimisation des binaires
echo "Optimizing binaries..."
cd ${INSTALL_DIR}/bin
${STRIP} --strip-all --remove-section=.comment --remove-section=.note php
cd ${INSTALL_DIR}/sbin
${STRIP} --strip-all --remove-section=.comment --remove-section=.note php-fpm

# Création de la configuration PHP optimisée
echo "Creating optimized PHP configuration..."
mkdir -p ${INSTALL_DIR}/etc/conf.d
cat > ${INSTALL_DIR}/etc/php.ini << 'EOF'
[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions =
disable_classes =
zend.enable_gc = On
zend.exception_ignore_args = On
expose_php = Off
max_execution_time = 30
max_input_time = 60
memory_limit = 128M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 8M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
file_uploads = On
upload_max_filesize = 2M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
EOF

# Création de la structure finale
echo "Creating final structure..."
mkdir -p ${INSTALL_DIR}/var/log
mkdir -p ${INSTALL_DIR}/var/run
mkdir -p ${INSTALL_DIR}/tmp

# Création de l'archive
echo "Creating archive..."
cd /tmp
ARCHIVE_NAME="php-static-${BUILD_ARCH}-linux.tar.gz"
tar -czf ${ARCHIVE_NAME} -C ${INSTALL_DIR} .

# Copie de l'archive vers le répertoire de sortie
echo "Copying archive to output directory..."
if [ -d "/output" ]; then
    cp ${ARCHIVE_NAME} /output/
    echo "Archive copied to /output/${ARCHIVE_NAME}"
else
    echo "Warning: /output directory not found, archive not copied"
fi

echo "Build completed successfully!"
echo "Archive created: /tmp/${ARCHIVE_NAME}"

# Test rapide du binaire
echo "Testing binary..."
${INSTALL_DIR}/bin/php --version
${INSTALL_DIR}/sbin/php-fpm --version

echo "=== Build completed ==="
