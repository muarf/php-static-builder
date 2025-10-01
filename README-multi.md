# PHP Static Binaries Builder (Multi-Platform)

Ce projet compile des binaires PHP statiques pour plusieurs plateformes : Linux x86_64, Linux ARM64, et potentiellement macOS.

## 🎯 Objectif

Créer des binaires PHP statiques portables pour :
- **Linux x86_64** (Ubuntu, Debian, CentOS, etc.)
- **Linux ARM64** (AWS Graviton, Raspberry Pi, etc.)
- **macOS x86_64** (Intel Macs)
- **macOS ARM64** (Apple Silicon M1/M2/M3)

## 🚀 Utilisation

### Prérequis

```bash
# Docker avec Buildx
docker --version
docker buildx version

# Configuration Buildx
make setup-buildx
```

### Construction des binaires

```bash
# Tous les binaires Linux
make -f Makefile.multi build-linux

# Tous les binaires (Linux + macOS si disponible)
make -f Makefile.multi build-all

# Tests
make -f Makefile.multi test
```

### Résultats

Les binaires sont générés dans `dist/` :
- `php-static-amd64-linux.tar.gz` - Linux x86_64
- `php-static-arm64-linux.tar.gz` - Linux ARM64
- `php-static-amd64-macos.tar.gz` - macOS x86_64 (si disponible)
- `php-static-arm64-macos.tar.gz` - macOS ARM64 (si disponible)

## 📦 Contenu des archives

Chaque archive contient :
```
./
├── bin/
│   ├── php          # Binaire PHP CLI
│   ├── php-config   # Configuration PHP
│   ├── phpize       # Outil de développement
│   └── phar         # Gestionnaire d'archives PHP
├── sbin/
│   └── php-fpm      # Binaire PHP-FPM
├── lib/
│   └── php/         # Bibliothèques et extensions
├── etc/
│   ├── php.ini      # Configuration PHP
│   └── conf.d/      # Configuration additionnelle
└── var/
    ├── log/         # Logs
    └── run/         # Fichiers de runtime
```

## 🔧 Utilisation des binaires

### Linux

```bash
# Extraire l'archive
tar -xzf php-static-amd64-linux.tar.gz

# Utiliser PHP CLI
./bin/php --version
./bin/php -r "echo 'Hello World!';"

# Utiliser PHP-FPM
./sbin/php-fpm --version
```

### macOS

```bash
# Extraire l'archive
tar -xzf php-static-amd64-macos.tar.gz

# Utiliser PHP CLI
./bin/php --version
./bin/php -r "echo 'Hello World!';"
```

## 🏗️ Architecture du projet

```
php-static-builder/
├── Dockerfile.multi          # Dockerfile multi-plateforme
├── Makefile.multi           # Makefile pour builds multi-plateforme
├── scripts/
│   ├── build-multi.sh       # Script de build multi-plateforme
│   └── build-php.sh         # Script de build original
├── config/                  # Configuration PHP
├── dist/                    # Binaires générés
└── README-multi.md          # Cette documentation
```

## 🐳 Docker Multi-Platform

Le projet utilise Docker Buildx pour la compilation multi-plateforme :

```bash
# Construction pour toutes les plateformes
docker buildx build --platform linux/amd64,linux/arm64 -t php-static-builder-multi .

# Construction pour une plateforme spécifique
docker buildx build --platform linux/amd64 -t php-static-builder-multi .
```

## 🔍 Limitations actuelles

### macOS
- **Problème** : Docker ne peut pas compiler pour macOS depuis Linux
- **Solutions** :
  1. Utiliser un Mac avec Xcode
  2. Cross-compiler avec osxcross
  3. GitHub Actions avec runners macOS
  4. Utiliser des binaires pré-compilés

### ARM64
- **Problème** : Cross-compilation complexe
- **Solution** : Utiliser Docker Buildx avec émulation QEMU

## 🚀 Améliorations futures

1. **Support macOS natif** avec cross-compilation
2. **Builds GitHub Actions** pour toutes les plateformes
3. **Signatures de binaires** pour la sécurité
4. **Tests automatisés** sur toutes les plateformes
5. **Optimisations spécifiques** par plateforme

## 📋 Commandes utiles

```bash
# Voir les plateformes supportées
docker buildx ls

# Inspecter une image multi-plateforme
docker buildx imagetools inspect php-static-builder-multi:latest

# Tester un binaire
file dist/php-static-amd64-linux.tar.gz
tar -tzf dist/php-static-amd64-linux.tar.gz | head -10
```

## 🤝 Contribution

Pour ajouter le support d'une nouvelle plateforme :

1. Modifier `Dockerfile.multi`
2. Ajouter la configuration dans `build-multi.sh`
3. Mettre à jour `Makefile.multi`
4. Tester sur la plateforme cible

## 📄 Licence

Ce projet est sous licence MIT.
