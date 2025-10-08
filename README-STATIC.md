# PHP Binaire Statique - Guide Complet

Ce projet propose **deux approches** pour créer des binaires PHP avec un maximum d'extensions :

## 🎯 Approche 1 : Build Optimisé (Recommandé)

**Fichiers :** `build-multi.sh`, `build-mac.sh`, `build-php.sh`, `build-windows.sh`

### Caractéristiques
- ✅ **Toutes les extensions demandées** incluses
- ✅ **Très portable** - Fonctionne sur la plupart des systèmes
- ⚠️ **Quelques dépendances dynamiques** (libc, libicu, libxml2, etc.)
- ✅ **Facile à builder** - Peu de problèmes de compatibilité

### Extensions incluses
- **Core**: opcache, session, phar, filter, tokenizer
- **Base de données**: mysqlnd, pdo, pdo-mysql, pdo-sqlite, mysqli, sqlite3
- **XML**: dom, xml, simplexml, xmlreader, xmlwriter, libxml
- **Compression**: bz2, zip, zlib
- **Réseau**: curl, ftp, sockets, openssl
- **Chaînes**: mbstring, iconv, gettext
- **Images**: gd (avec freetype, jpeg, png)
- **Système**: posix, pcntl, shmop, sysvmsg, sysvsem, sysvshm
- **Autres**: calendar, ctype, exif, ffi, fileinfo, intl, readline, bcmath

### Utilisation
```bash
# Build
make -f Makefile.multi build-linux

# Test
./dist/php-static-amd64-linux/bin/php --version
./dist/php-static-amd64-linux/bin/php -m
```

### Dépendances runtime (minimales)
Le binaire nécessite ces bibliothèques système (généralement présentes) :
- libc (glibc ou musl)
- libm (mathématiques)
- libpthread (threads)
- libdl (dynamic linking)
- libicu (internationalisation)
- libxml2, libssl, libcurl, etc.

---

## 🔒 Approche 2 : Build 100% Statique (Expérimental)

**Fichiers :** `Dockerfile.static`, `Makefile.static`

### Caractéristiques
- ✅ **100% statique** - Aucune dépendance externe
- ✅ **Vraiment autonome** - Fonctionne partout (même sans libc)
- ⚠️ **Moins d'extensions** - Certaines ne supportent pas le linking statique
- ⚠️ **Plus complexe** - Nécessite Alpine Linux + musl

### Extensions incluses (statique)
- **Core**: opcache, session, phar, filter, tokenizer
- **Base de données**: mysqlnd, pdo, pdo-mysql, pdo-sqlite, mysqli, sqlite3
- **XML**: dom, xml, simplexml, xmlreader, xmlwriter, libxml
- **Compression**: bz2, zip, zlib
- **Réseau**: openssl, ftp, sockets
- **Chaînes**: mbstring
- **Système**: posix, pcntl, shmop, sysvmsg, sysvsem, sysvshm
- **Autres**: calendar, ctype, exif, fileinfo, readline, bcmath

### Extensions NON incluses (problèmes en statique)
- ❌ curl - Problèmes de linking statique
- ❌ intl - ICU trop complexe en statique
- ❌ gd - Dépendances multiples difficiles
- ❌ ffi - Problèmes avec libffi statique
- ❌ iconv - Conflits avec musl
- ❌ gettext - Problèmes de linking

### Utilisation
```bash
# Build local
make -f Makefile.static build-static

# Test
./dist-static/php --version
ldd ./dist-static/php  # Doit afficher "not a dynamic executable"

# GitHub Actions
# Le workflow build-static.yml se déclenche automatiquement
```

### Vérification du binaire statique
```bash
# Vérifier qu'il est vraiment statique
file ./dist-static/php
# Output: ELF 64-bit LSB executable, x86-64, statically linked, stripped

ldd ./dist-static/php
# Output: not a dynamic executable

# Tester sur un système minimal (sans bibliothèques)
docker run --rm -v $(pwd)/dist-static:/app alpine:latest /app/php --version
```

---

## 📊 Comparaison

| Critère | Build Optimisé | Build 100% Statique |
|---------|----------------|---------------------|
| **Extensions** | 40+ extensions | 30+ extensions |
| **Taille** | ~5-10 MB | ~15-20 MB |
| **Dépendances** | Quelques libs système | Aucune |
| **Portabilité** | Très bonne | Excellente |
| **Facilité build** | ✅ Facile | ⚠️ Complexe |
| **Recommandé pour** | Production | Conteneurs/Embedded |

---

## 🚀 Quelle approche choisir ?

### Choisir le **Build Optimisé** si :
- ✅ Vous voulez **toutes les extensions** (curl, gd, intl, etc.)
- ✅ Vous déployez sur des **systèmes standards** (Ubuntu, Debian, CentOS, etc.)
- ✅ Vous voulez la **meilleure compatibilité**
- ✅ Les dépendances système ne vous dérangent pas

### Choisir le **Build 100% Statique** si :
- ✅ Vous voulez un binaire **vraiment autonome**
- ✅ Vous déployez dans des **conteneurs minimaux** (scratch, distroless)
- ✅ Vous n'avez pas besoin de curl, gd, intl
- ✅ La taille du binaire n'est pas critique

---

## 📝 Notes importantes

### Build Statique avec musl
- Le binaire est compilé avec **musl libc** au lieu de glibc
- Toutes les bibliothèques sont **linkées statiquement**
- Le binaire peut tourner sur **n'importe quel Linux** (même sans libc installée)
- Parfait pour les **conteneurs Docker** ultra-minimalistes

### Limitations du Build Statique
Certaines extensions sont difficiles/impossibles à compiler en 100% statique :
- **curl** - Dépend de nombreuses bibliothèques (nghttp2, zstd, brotli, etc.)
- **intl** - ICU est énorme et complexe en statique
- **gd** - Multiples dépendances (libpng, libjpeg, freetype, etc.)
- **iconv** - Conflits entre musl iconv et GNU iconv

### Solution Hybride
Pour avoir curl, gd, intl ET un binaire portable, utilisez l'**Approche 1** (Build Optimisé) qui offre le meilleur compromis entre fonctionnalités et portabilité.

---

## 🔧 Développement

### Ajouter une extension
1. Ajouter la dépendance dans `Dockerfile.multi` ou `Dockerfile.static`
2. Ajouter l'option `--enable-XXX` ou `--with-XXX` dans le script de build
3. Tester localement
4. Pousser et vérifier le build GitHub Actions

### Déboguer un problème de build
```bash
# Voir les logs détaillés
gh run view <run-id> --log | grep -A 20 "configure: error"

# Builder localement pour déboguer
docker build -f Dockerfile.static -t test .

# Entrer dans le conteneur pour investiguer
docker run --rm -it alpine:3.19 sh
```

---

## 📦 Releases

Les releases GitHub contiennent les binaires des deux approches :
- `php-static-amd64-linux.tar.gz` - Build optimisé (toutes extensions)
- `php-static-musl-amd64-linux.tar.gz` - Build 100% statique (extensions limitées)

Choisissez celui qui correspond à vos besoins !
