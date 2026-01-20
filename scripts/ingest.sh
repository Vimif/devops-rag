#!/bin/bash
#===============================================================================
# Script d'ingestion de la documentation
# Indexe automatiquement les fichiers dans ./docs/ via Open WebUI
#===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs"
OPENWEBUI_URL="http://localhost:3000"

echo "=================================================="
echo "  Ingestion de la documentation DevOps"
echo "=================================================="
echo ""

#-------------------------------------------------------------------------------
# Vérifications
#-------------------------------------------------------------------------------

# Vérifier que les services sont actifs
if ! curl -s "$OPENWEBUI_URL" > /dev/null; then
    echo "❌ Open WebUI n'est pas accessible sur $OPENWEBUI_URL"
    echo "   Lancez d'abord: docker compose up -d"
    exit 1
fi

# Vérifier le dossier docs
if [ ! -d "$DOCS_DIR" ]; then
    mkdir -p "$DOCS_DIR"
    echo "📁 Dossier $DOCS_DIR créé"
fi

#-------------------------------------------------------------------------------
# Lister les fichiers supportés
#-------------------------------------------------------------------------------
echo "📄 Fichiers trouvés dans $DOCS_DIR:"
echo ""

# Extensions supportées
EXTENSIONS=("md" "txt" "yaml" "yml" "json" "py" "sh" "bash" "dockerfile" "tf" "hcl" "toml" "ini" "cfg" "conf" "xml" "html" "css" "js" "ts" "go" "rs" "java" "sql" "groovy")

total_files=0
for ext in "${EXTENSIONS[@]}"; do
    count=$(find "$DOCS_DIR" -type f -iname "*.$ext" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "  .$ext: $count fichier(s)"
        total_files=$((total_files + count))
    fi
done

# Fichiers sans extension (Dockerfile, Makefile, etc.)
special_files=$(find "$DOCS_DIR" -type f \( -name "Dockerfile*" -o -name "Makefile" -o -name "Jenkinsfile" -o -name ".gitlab-ci*" -o -name ".github*" \) 2>/dev/null | wc -l)
if [ "$special_files" -gt 0 ]; then
    echo "  (spéciaux): $special_files fichier(s)"
    total_files=$((total_files + special_files))
fi

echo ""
echo "Total: $total_files fichier(s) à indexer"
echo ""

if [ "$total_files" -eq 0 ]; then
    echo "⚠️  Aucun fichier trouvé dans $DOCS_DIR"
    echo ""
    echo "Placez vos fichiers de documentation dans ce dossier:"
    echo "  $DOCS_DIR"
    echo ""
    echo "Formats supportés:"
    echo "  • Documentation: .md, .txt, .html"
    echo "  • Configuration: .yaml, .yml, .json, .toml, .ini"
    echo "  • Infrastructure: .tf, .hcl, Dockerfile, docker-compose.yml"
    echo "  • Scripts: .sh, .bash, .py, Makefile, Jenkinsfile"
    echo "  • CI/CD: .gitlab-ci.yml, .github/workflows/*.yml"
    echo "  • Code: .py, .go, .js, .ts, .java, .rs"
    exit 0
fi

#-------------------------------------------------------------------------------
# Instructions d'ingestion via Open WebUI
#-------------------------------------------------------------------------------
echo "=================================================="
echo "  Instructions d'ingestion"
echo "=================================================="
echo ""
echo "Open WebUI gère l'ingestion via son interface web."
echo ""
echo "➡️  Méthode 1: Upload manuel (recommandé pour commencer)"
echo "   1. Ouvrez http://localhost:3000"
echo "   2. Cliquez sur votre profil → Settings → Documents"
echo "   3. Cliquez sur '+' pour uploader vos fichiers"
echo "   4. Les fichiers sont dans: $DOCS_DIR"
echo ""
echo "➡️  Méthode 2: API (pour automatisation)"
echo "   Voir le script ingest_api.py pour l'ingestion programmatique"
echo ""
echo "=================================================="
echo ""

# Demander si l'utilisateur veut ouvrir l'interface
read -p "Ouvrir Open WebUI dans le navigateur ? (o/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Oo]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$OPENWEBUI_URL" 2>/dev/null &
    elif command -v gnome-open &> /dev/null; then
        gnome-open "$OPENWEBUI_URL" 2>/dev/null &
    else
        echo "Ouvrez manuellement: $OPENWEBUI_URL"
    fi
fi
