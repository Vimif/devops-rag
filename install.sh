#!/bin/bash
#===============================================================================
# Installation du système RAG DevOps auto-hébergé
# Ubuntu 24.04 LTS + NVIDIA RTX 3080
#===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=================================================="
echo "  Installation du système RAG DevOps"
echo "  Ubuntu 24.04 + RTX 3080 (10GB VRAM)"
echo "=================================================="
echo ""

#-------------------------------------------------------------------------------
# 1. Vérification des prérequis
#-------------------------------------------------------------------------------
echo "[1/6] Vérification des prérequis..."

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi
echo "  ✓ Docker installé"

# Vérifier que l'utilisateur peut utiliser Docker sans sudo
if ! docker ps &> /dev/null; then
    echo "❌ Impossible d'exécuter Docker. Ajoutez votre utilisateur au groupe docker:"
    echo "   sudo usermod -aG docker $USER"
    echo "   Puis déconnectez-vous et reconnectez-vous."
    exit 1
fi
echo "  ✓ Permissions Docker OK"

# Vérifier le GPU NVIDIA
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ nvidia-smi non trouvé. Installez les drivers NVIDIA."
    exit 1
fi
echo "  ✓ Driver NVIDIA installé"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

#-------------------------------------------------------------------------------
# 2. Installation de NVIDIA Container Toolkit
#-------------------------------------------------------------------------------
echo ""
echo "[2/6] Vérification de NVIDIA Container Toolkit..."

if ! dpkg -l | grep -q nvidia-container-toolkit; then
    echo "  Installation de NVIDIA Container Toolkit..."
    
    # Ajouter le repository NVIDIA
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    
    # Configurer Docker pour utiliser le runtime NVIDIA
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    
    echo "  ✓ NVIDIA Container Toolkit installé"
else
    echo "  ✓ NVIDIA Container Toolkit déjà installé"
fi

# Vérifier que Docker peut accéder au GPU
echo "  Test d'accès GPU depuis Docker..."
if docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi &> /dev/null; then
    echo "  ✓ Docker peut accéder au GPU"
else
    echo "❌ Docker ne peut pas accéder au GPU. Redémarrez le système et réessayez."
    exit 1
fi

#-------------------------------------------------------------------------------
# 3. Création de la structure de dossiers
#-------------------------------------------------------------------------------
echo ""
echo "[3/6] Création de la structure de dossiers..."

mkdir -p "$SCRIPT_DIR"/{data,docs,scripts}
mkdir -p "$SCRIPT_DIR"/data/{ollama,qdrant,open-webui}

echo "  ✓ Structure créée:"
echo "    ./data/ollama/      - Modèles LLM"
echo "    ./data/qdrant/      - Base vectorielle"
echo "    ./data/open-webui/  - Configuration UI"
echo "    ./docs/             - Votre documentation à indexer"

#-------------------------------------------------------------------------------
# 4. Démarrage des services
#-------------------------------------------------------------------------------
echo ""
echo "[4/6] Démarrage des services Docker..."

docker compose up -d

echo "  Attente du démarrage des services..."
sleep 10

# Vérifier que les services sont up
if docker compose ps | grep -q "unhealthy\|Exit"; then
    echo "❌ Certains services n'ont pas démarré correctement:"
    docker compose ps
    exit 1
fi
echo "  ✓ Services démarrés"

#-------------------------------------------------------------------------------
# 5. Téléchargement des modèles
#-------------------------------------------------------------------------------
echo ""
echo "[5/6] Téléchargement des modèles (peut prendre plusieurs minutes)..."

# Modèle LLM principal - Qwen 2.5 Coder 7B (optimisé pour votre 3080)
echo "  Téléchargement de Qwen 2.5 Coder 7B..."
docker exec ollama ollama pull qwen2.5-coder:7b-instruct

# Modèle d'embeddings
echo "  Téléchargement de nomic-embed-text..."
docker exec ollama ollama pull nomic-embed-text

# Optionnel: modèle plus gros si vous voulez tester (à la limite des 10GB)
# echo "  Téléchargement de Qwen 2.5 Coder 14B (optionnel)..."
# docker exec ollama ollama pull qwen2.5-coder:14b-instruct-q4_K_M

echo "  ✓ Modèles téléchargés"

#-------------------------------------------------------------------------------
# 6. Vérification finale
#-------------------------------------------------------------------------------
echo ""
echo "[6/6] Vérification finale..."

# Test Ollama
echo "  Test du modèle LLM..."
RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b-instruct",
  "prompt": "Réponds uniquement: OK",
  "stream": false
}' | grep -o '"response":"[^"]*"' | head -1)

if [[ "$RESPONSE" == *"OK"* ]] || [[ -n "$RESPONSE" ]]; then
    echo "  ✓ Ollama fonctionne"
else
    echo "  ⚠ Ollama peut avoir besoin de plus de temps pour charger"
fi

# Test Qdrant
if curl -s http://localhost:6333/healthz | grep -q "ok"; then
    echo "  ✓ Qdrant fonctionne"
else
    echo "  ⚠ Qdrant peut avoir besoin de plus de temps"
fi

# Test Open WebUI
if curl -s http://localhost:3000 | grep -q "Open WebUI"; then
    echo "  ✓ Open WebUI accessible"
else
    echo "  ⚠ Open WebUI peut avoir besoin de plus de temps"
fi

#-------------------------------------------------------------------------------
# Résumé
#-------------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "  ✅ Installation terminée !"
echo "=================================================="
echo ""
echo "Accès aux services:"
echo "  • Open WebUI:  http://localhost:3000"
echo "  • Ollama API:  http://localhost:11434"
echo "  • Qdrant:      http://localhost:6333/dashboard"
echo ""
echo "Prochaines étapes:"
echo "  1. Ouvrez http://localhost:3000"
echo "  2. Créez un compte administrateur"
echo "  3. Allez dans Settings → Models → sélectionnez qwen2.5-coder:7b-instruct"
echo "  4. Placez vos fichiers de documentation dans ./docs/"
echo "  5. Exécutez: ./scripts/ingest.sh"
echo ""
echo "Commandes utiles:"
echo "  docker compose logs -f      # Voir les logs"
echo "  docker compose restart      # Redémarrer"
echo "  docker compose down         # Arrêter"
echo "  ./scripts/ingest.sh         # Indexer la documentation"
echo ""
