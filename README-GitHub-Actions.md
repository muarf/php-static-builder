# PHP Static Binaries Builder - GitHub Actions

Ce projet utilise GitHub Actions pour compiler des binaires PHP statiques pour plusieurs plateformes.

## 🚀 Workflows GitHub Actions

### 1. **Build Multi-Platform** (`.github/workflows/build-multi-platform.yml`)

Compile des binaires PHP statiques pour :
- **Linux** : x86_64, ARM64
- **macOS** : Intel, Apple Silicon  
- **Windows** : x86_64, ARM64

#### Déclencheurs
- Push sur `main` ou `develop`
- Pull Request vers `main`
- Release publiée
- Déclenchement manuel

#### Jobs
- `build-linux` : Compilation Linux avec Docker Buildx
- `build-macos` : Compilation macOS native
- `build-windows` : Compilation Windows native
- `test-binaries` : Tests des binaires générés
- `release` : Création automatique de release
- `summary` : Résumé des builds

### 2. **Test** (`.github/workflows/test.yml`)

Tests et validation :
- Test des binaires existants
- Validation des scripts de build
- Linting des fichiers YAML et shell

## 📦 Scripts de Build

### Linux (`scripts/build-multi.sh`)
- Utilise Docker Buildx pour la compilation
- Support x86_64 et ARM64
- Optimisations de taille

### macOS (`scripts/build-mac.sh`)
- Compilation native sur macOS
- Support Intel et Apple Silicon
- Utilise les outils de développement Apple

### Windows (`scripts/build-windows.sh`)
- Compilation native sur Windows
- Support x86_64 et ARM64
- Utilise Visual Studio Build Tools

## 🔧 Configuration

### Variables d'environnement
```yaml
env:
  PHP_VERSION: "8.2.14"
```

### Matrices de build
```yaml
strategy:
  matrix:
    arch: [amd64, arm64]
```

## 📋 Utilisation

### 1. **Déclenchement automatique**
```bash
# Push sur main ou develop
git push origin main

# Créer une release
git tag v1.0.0
git push origin v1.0.0
```

### 2. **Déclenchement manuel**
- Aller dans l'onglet "Actions" du repository
- Sélectionner "Build PHP Static Binaries (Multi-Platform)"
- Cliquer sur "Run workflow"

### 3. **Téléchargement des artefacts**
- Aller dans l'onglet "Actions"
- Ouvrir le workflow terminé
- Télécharger les artefacts dans "Artifacts"

## 🎯 Résultats

### Archives générées
- `php-static-amd64-linux.tar.gz` - Linux x86_64
- `php-static-arm64-linux.tar.gz` - Linux ARM64
- `php-static-amd64-macos.tar.gz` - macOS Intel
- `php-static-arm64-macos.tar.gz` - macOS Apple Silicon
- `php-static-amd64-windows.tar.gz` - Windows x86_64
- `php-static-arm64-windows.tar.gz` - Windows ARM64

### Contenu des archives
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

## 🔍 Tests

### Tests automatiques
- Validation des binaires générés
- Test de version PHP
- Test de fonctionnalité de base
- Vérification des extensions

### Tests manuels
```bash
# Extraire l'archive
tar -xzf php-static-amd64-linux.tar.gz

# Tester PHP CLI
./bin/php --version
./bin/php -r "echo 'Hello World!';"

# Tester PHP-FPM
./sbin/php-fpm --version

# Lister les extensions
./bin/php -m
```

## 📊 Monitoring

### Résumé des builds
Chaque workflow génère un résumé avec :
- Statut de chaque plateforme
- Version PHP compilée
- Date de build
- Liens vers les artefacts

### Notifications
- Échec de build : notification automatique
- Succès de release : notification avec liens de téléchargement

## 🛠️ Développement

### Ajouter une nouvelle plateforme
1. Créer un script de build dans `scripts/`
2. Ajouter un job dans le workflow
3. Mettre à jour la matrice de build
4. Tester localement

### Modifier la configuration PHP
1. Éditer les scripts de build
2. Tester avec un workflow de test
3. Valider les changements

### Débogage
- Consulter les logs GitHub Actions
- Tester localement avec Docker
- Vérifier les dépendances système

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Buildx](https://docs.docker.com/buildx/)
- [PHP Build Documentation](https://www.php.net/manual/en/install.unix.php)
- [Cross-compilation Guide](https://gcc.gnu.org/onlinedocs/gcc/Cross-Compilation.html)

## 🤝 Contribution

1. Fork le repository
2. Créer une branche feature
3. Modifier les workflows ou scripts
4. Tester avec GitHub Actions
5. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.
