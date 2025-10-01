# Dockerfile pour la compilation de PHP statique
FROM ubuntu:22.04

ARG PHP_VERSION=8.2.14
ARG TARGET_ARCH=x86_64-linux-gnu
ARG BUILD_ARCH=x86_64

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=${PHP_VERSION}
ENV TARGET_ARCH=${TARGET_ARCH}
ENV BUILD_ARCH=${BUILD_ARCH}
ENV BUILD_DIR=/tmp/php-build
ENV INSTALL_DIR=/tmp/php-static

# Mise à jour du système et installation des dépendances
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    pkg-config \
    autoconf \
    automake \
    libtool \
    bison \
    re2c \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libsqlite3-dev \
    libreadline-dev \
    libedit-dev \
    libc6-dev \
    libgcc-s1 \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Installation des outils de cross-compilation si nécessaire
RUN if [ "${BUILD_ARCH}" = "aarch64" ]; then \
        apt-get update && apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Copie des scripts de build
COPY scripts/ /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh

# Création des répertoires de travail
RUN mkdir -p ${BUILD_DIR} ${INSTALL_DIR}

# Copie de la configuration PHP
COPY config/ /tmp/config/

# Point d'entrée
ENTRYPOINT ["/tmp/scripts/build-php.sh"]
