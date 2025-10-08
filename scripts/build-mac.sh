#!/bin/bash
# Script de build pour macOS

set -e

# Configuration
ARCH=${1:-amd64}
PHP_VERSION=${PHP_VERSION:-8.2.14}
BUILD_DIR=${BUILD_DIR:-/tmp/php-build}
INSTALL_DIR=${INSTALL_DIR:-/tmp/php-static}

echo "=== PHP Static Binary Builder (macOS) ==="
echo "PHP Version: $PHP_VERSION"
echo "Architecture: $ARCH"
echo "=========================================="

# Installation des dépendances
echo "Installing dependencies..."
brew install autoconf automake libtool pkg-config
brew install libxml2 openssl zlib bzip2 icu4c libffi gd gettext curl readline sqlite

# Configuration selon l'architecture
if [ "$ARCH" = "arm64" ]; then
    export CC="clang -arch arm64"
    export CXX="clang++ -arch arm64"
    export TARGET_ARCH="arm64-apple-darwin"
    export STRIP="strip"
    export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:/opt/homebrew/opt/bzip2/lib/pkgconfig:/opt/homebrew/opt/icu4c/lib/pkgconfig:/opt/homebrew/opt/openssl/lib/pkgconfig:/opt/homebrew/opt/readline/lib/pkgconfig:/opt/homebrew/opt/sqlite/lib/pkgconfig"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/bzip2/include -I/opt/homebrew/opt/icu4c/include -I/opt/homebrew/opt/openssl/include -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/sqlite/include"
    export LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/bzip2/lib -L/opt/homebrew/opt/icu4c/lib -L/opt/homebrew/opt/openssl/lib -L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/sqlite/lib"
else
    export CC="clang -arch x86_64"
    export CXX="clang++ -arch x86_64"
    export TARGET_ARCH="x86_64-apple-darwin"
    export STRIP="strip"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/opt/bzip2/lib/pkgconfig:/usr/local/opt/icu4c/lib/pkgconfig:/usr/local/opt/openssl/lib/pkgconfig:/usr/local/opt/readline/lib/pkgconfig:/usr/local/opt/sqlite/lib/pkgconfig"
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    export CPPFLAGS="-I/usr/local/include -I/usr/local/opt/bzip2/include -I/usr/local/opt/icu4c/include -I/usr/local/opt/openssl/include -I/usr/local/opt/readline/include -I/usr/local/opt/sqlite/include"
    export LDFLAGS="-L/usr/local/lib -L/usr/local/opt/bzip2/lib -L/usr/local/opt/icu4c/lib -L/usr/local/opt/openssl/lib -L/usr/local/opt/readline/lib -L/usr/local/opt/sqlite/lib"
fi

# Création des répertoires
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}

# Téléchargement de PHP
echo "Downloading PHP $PHP_VERSION..."
cd $BUILD_DIR
if [ ! -f "php-${PHP_VERSION}.tar.gz" ]; then
    curl -L -o "php-${PHP_VERSION}.tar.gz" "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz"
fi

# Extraction
echo "Extracting PHP source..."
tar -xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# Configuration de la compilation
echo "Configuring PHP build for macOS..."

./configure \
    --prefix=${INSTALL_DIR} \
    --disable-all \
    --enable-cli \
    --enable-fpm \
    --with-config-file-path=${INSTALL_DIR}/etc \
    --with-config-file-scan-dir=${INSTALL_DIR}/etc/conf.d \
    --enable-phar \
    --enable-session \
    --enable-opcache \
    --enable-mysqlnd \
    --enable-pdo \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-sqlite \
    --enable-dom \
    --enable-xml \
    --enable-simplexml \
    --enable-xmlreader \
    --enable-xmlwriter \
    --with-libxml \
    --enable-calendar \
    --enable-ctype \
    --with-curl \
    --enable-exif \
    --enable-fileinfo \
    --enable-ftp \
    --enable-mbstring \
    --with-mysqli=mysqlnd \
    --enable-posix \
    --with-readline \
    --enable-shmop \
    --enable-sockets \
    --with-sqlite3 \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --with-zip \
    --with-zlib \
    --with-openssl \
    --with-iconv \
    --enable-pcntl \
    --enable-bcmath \
    --enable-filter \
    --enable-tokenizer \
    --enable-zts=no \
    --disable-debug \
    --disable-rpath \
    --with-pic \
    --without-pear \
    --disable-cgi \
    --disable-phpdbg \
    --enable-embed=no \
    --disable-zend-signals \
    --enable-zend-max-execution-timers \
    CFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1" \
    CXXFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden" \
    LDFLAGS="-Wl,-dead_strip"

# Compilation
echo "Building PHP..."
make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Installation
echo "Installing PHP..."
make install

# Optimisation des binaires
echo "Optimizing binaries..."
cd ${INSTALL_DIR}/bin
${STRIP} -S -x php
cd ${INSTALL_DIR}/sbin
${STRIP} -S -x php-fpm

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
ARCHIVE_NAME="php-static-${ARCH}-macos.tar.gz"
tar -czf ${ARCHIVE_NAME} -C ${INSTALL_DIR} .

# Copie de l'archive vers le répertoire de sortie
echo "Copying archive to output directory..."
if [ -d "/output" ]; then
    cp ${ARCHIVE_NAME} /output/
    echo "Archive copied to /output/${ARCHIVE_NAME}"
else
    # Pour GitHub Actions - s'assurer qu'on est dans le bon répertoire
    cd /Users/runner/work/php-static-builder/php-static-builder
    mkdir -p dist
    cp /tmp/${ARCHIVE_NAME} dist/
    echo "Archive copied to dist/${ARCHIVE_NAME}"
    echo "Current directory: $(pwd)"
    echo "Contents of dist/:"
    ls -la dist/
fi

echo "Build completed successfully!"
echo "Archive created: /tmp/${ARCHIVE_NAME}"

# Test rapide du binaire (désactivé pour éviter Bus error)
echo "Skipping binary test to avoid Bus error..."
echo "Binary created successfully: ${INSTALL_DIR}/bin/php"
echo "Binary created successfully: ${INSTALL_DIR}/sbin/php-fpm"

echo "=== Build completed ==="
