# Architecture du projet

## Vue d'ensemble

Ce projet compile des binaires PHP statiques pour différentes architectures Linux en utilisant Docker et GitHub Actions.

## Structure du projet

```
php-static-builder/
├── .github/
│   ├── workflows/          # GitHub Actions
│   ├── ISSUE_TEMPLATE/     # Templates d'issues
│   └── dependabot.yml      # Mise à jour automatique des dépendances
├── scripts/                # Scripts de build
├── config/                 # Configurations PHP
├── tests/                  # Tests de validation
├── docs/                   # Documentation
├── Dockerfile             # Image Docker pour la compilation
├── README.md              # Documentation principale
└── LICENSE                # Licence MIT
```

## Processus de build

### 1. Déclenchement
- Push sur `main`/`master`
- Pull Request
- Création d'une Release

### 2. Compilation multi-architecture
- Utilisation de Docker Buildx
- Support x86_64 et aarch64
- Compilation en parallèle

### 3. Optimisation des binaires
- Stripping des symboles
- Optimisation des flags de compilation
- Suppression des dépendances dynamiques

### 4. Tests et validation
- Tests fonctionnels
- Tests de performance
- Tests d'intégration

### 5. Publication
- Upload sur GitHub Releases
- Artifacts disponibles pour téléchargement

## Technologies utilisées

- **Docker**: Isolation et reproductibilité
- **GitHub Actions**: CI/CD automatique
- **Ubuntu 22.04**: Base de compilation
- **GCC**: Compilateur C/C++
- **PHP 8.3**: Version cible

## Extensions PHP incluses

### Extensions core
- Core PHP functions
- JSON
- Hash
- Session
- Filter
- Tokenizer
- Opcache

### Extensions standard
- Fileinfo
- Mbstring
- Ctype
- PDO
- SQLite3
- ZIP
- GD
- cURL
- OpenSSL

### Extensions système
- Bcmath
- Calendar
- Exif
- POSIX
- Sysvshm
- Sysvsem
- Sysvmsg
- Shmop
- PCNTL
- Readline
- SimpleXML
- XML
- XMLReader
- XMLWriter
- DOM
- LibXML
- PHAR
- MySQLnd
- MySQLi
- PDO_MySQL
- Intl
- Gettext
- SOAP

## Optimisations appliquées

### Compilation
- Flags d'optimisation `-Os`
- Suppression des sections inutiles
- Visibilité cachée des symboles
- Cache statique TSRMLS

### Linking
- Suppression des sections inutiles
- Linking statique de libgcc/libstdc++
- Stripping complet des symboles

### Configuration PHP
- Configuration optimisée pour la performance
- OPcache activé
- Gestion d'erreurs adaptée
- Timezone UTC par défaut

## Sécurité

- Binaires compilés sans debug info
- Pas d'exposition de PHP (`expose_php = Off`)
- Fonctions dangereuses désactivées par défaut
- Configuration sécurisée par défaut

## Maintenance

### Mise à jour des dépendances
- Dependabot configuré
- Mise à jour hebdomadaire des GitHub Actions

### Tests
- Tests automatisés à chaque build
- Validation des binaires
- Tests de performance
- Tests d'intégration

### Documentation
- README complet
- Architecture documentée
- Templates d'issues
- Guide de contribution
