# PHP Static Binaries Builder

Ce projet compile automatiquement des binaires PHP statiques pour différentes architectures et les publie sur GitHub Releases.

## Fonctionnalités

- ✅ Compilation automatique via GitHub Actions
- ✅ Publication des binaires sur GitHub Releases
- ✅ Support multi-architecture (x64, arm64)
- ✅ Binaires statiques (pas de dépendances système)
- ✅ Inclut PHP et PHP-FPM
- ✅ Tests de validation des binaires
- ✅ Optimisé pour une taille minimale

## Architectures supportées

- `x86_64` (Linux)
- `aarch64` (ARM64 Linux)

## Utilisation

Les binaires sont automatiquement compilés et publiés lors de chaque push sur la branche `main`. Vous pouvez télécharger les binaires depuis la section [Releases](../../releases).

### Téléchargement programmatique

```bash
# Récupérer la dernière version
LATEST_VERSION=$(curl -s https://api.github.com/repos/VOTRE_ORG/VOTRE_REPO/releases/latest | jq -r '.tag_name')

# Télécharger pour x86_64
curl -L "https://github.com/VOTRE_ORG/VOTRE_REPO/releases/download/${LATEST_VERSION}/php-static-x86_64-linux.tar.gz" -o php-static-x86_64-linux.tar.gz

# Télécharger pour aarch64
curl -L "https://github.com/VOTRE_ORG/VOTRE_REPO/releases/download/${LATEST_VERSION}/php-static-aarch64-linux.tar.gz" -o php-static-aarch64-linux.tar.gz
```

## Structure des binaires

```
php-static/
├── bin/
│   ├── php          # Interpréteur PHP principal
│   └── php-fpm      # Process Manager FastCGI
├── lib/
│   └── php/         # Extensions PHP compilées
└── etc/
    └── php.ini      # Configuration par défaut
```

## Extensions incluses

- Core PHP extensions
- Standard library extensions
- Extensions optimisées pour la performance

## Développement local

Pour tester la compilation localement :

```bash
# Cloner le projet
git clone <repo-url>
cd php-static-builder

# Tester la compilation (nécessite Docker)
./scripts/test-build.sh
```

## Licence

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails.
