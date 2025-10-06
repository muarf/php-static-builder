#!/bin/bash

set -e

echo "=== PHP Static Binary Builder ==="
echo "PHP Version: ${PHP_VERSION}"
echo "Target Architecture: ${TARGET_ARCH}"
echo "Build Architecture: ${BUILD_ARCH}"

# Configuration des variables de compilation
if [ "${BUILD_ARCH}" = "aarch64" ]; then
    export CC=aarch64-linux-gnu-gcc
    export CXX=aarch64-linux-gnu-g++
    export AR=aarch64-linux-gnu-ar
    export RANLIB=aarch64-linux-gnu-ranlib
    export STRIP=aarch64-linux-gnu-strip
    export CROSS_COMPILE=aarch64-linux-gnu-
else
    export CC=gcc
    export CXX=g++
    export AR=ar
    export RANLIB=ranlib
    export STRIP=strip
fi

# Téléchargement de PHP
echo "Downloading PHP ${PHP_VERSION}..."
cd ${BUILD_DIR}
wget -q "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz"
tar -xzf "php-${PHP_VERSION}.tar.gz"
cd "php-${PHP_VERSION}"

# Configuration de la compilation
echo "Configuring PHP build..."

# Patch pour corriger l'erreur struct sigaction
echo "Applying sigaction patch..."
sed -i '1i#include <signal.h>' /tmp/php-build/php-${PHP_VERSION}/Zend/zend_globals.h

# Configuration des options de cross-compilation
CROSS_COMPILE_OPTS=""
if [ "${BUILD_ARCH}" = "aarch64" ]; then
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
    --with-bz2 \
    --enable-calendar \
    --enable-ctype \
    --with-curl \
    --enable-exif \
    --with-ffi \
    --enable-fileinfo \
    --enable-ftp \
    --with-gd \
    --with-external-gd \
    --with-freetype \
    --with-jpeg \
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
    --enable-intl \
    --with-iconv \
    --with-gettext \
    --enable-pcntl \
    --enable-bcmath \
    --enable-filter \
    --enable-tokenizer \
    --enable-zts=no \
    --disable-debug \
    --disable-rpath \
    --without-pear \
    --disable-cgi \
    --disable-phpdbg \
    --enable-embed=no \
    --disable-zend-signals \
    --enable-zend-max-execution-timers \
    CFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1 -D_GNU_SOURCE -static" \
    CXXFLAGS="-Os -ffunction-sections -fdata-sections -fvisibility=hidden -D_GNU_SOURCE -static" \
    LDFLAGS="-Wl,--gc-sections -Wl,--strip-all -static -static-libgcc -static-libstdc++" \
    LIBS="-ldl -lpthread"

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
cat > ${INSTALL_DIR}/etc/php.ini << 'INICONF'
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
zend.exception_string_param_max_len = 15
expose_php = Off

[opcache]
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1

[Date]
date.timezone = UTC

[mbstring]
mbstring.language = neutral
mbstring.internal_encoding = UTF-8

[curl]
curl.cainfo = 

[openssl]
openssl.cafile = 
openssl.capath = 
INICONF

# Création de la structure finale
echo "Creating final structure..."
mkdir -p ${INSTALL_DIR}/etc/conf.d
mkdir -p ${INSTALL_DIR}/lib/php

# Création de l'archive
echo "Creating archive..."
cd /tmp
tar -czf php-static.tar.gz -C ${INSTALL_DIR} .

# Copie de l'archive vers le répertoire de sortie
echo "Copying archive to output directory..."
if [ -d "/output" ]; then
    cp php-static.tar.gz /output/php-static-${BUILD_ARCH}-linux.tar.gz
    echo "Archive copied to /output/php-static-${BUILD_ARCH}-linux.tar.gz"
else
    echo "Warning: /output directory not found, archive not copied"
fi

echo "Build completed successfully!"
echo "Archive created: /tmp/php-static.tar.gz"

# Test rapide du binaire
echo "Testing binary..."
${INSTALL_DIR}/bin/php --version
${INSTALL_DIR}/sbin/php-fpm --version

echo "=== Build completed ==="
