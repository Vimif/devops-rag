# 🤖 Assistant IA DevOps Auto-hébergé

Système RAG (Retrieval-Augmented Generation) 100% local pour assister les projets DevOps.

## 📋 Prérequis

- **OS**: Ubuntu 24.04 LTS
- **GPU**: NVIDIA RTX 3080 (10GB VRAM)
- **RAM**: 16GB minimum (32GB recommandé)
- **Docker**: Installé et configuré
- **Stockage**: ~50GB libre

## 🚀 Installation rapide

```bash
# 1. Cloner ou copier ce dossier
cd devops-rag

# 2. Rendre le script exécutable
chmod +x install.sh scripts/*.sh

# 3. Lancer l'installation
./install.sh
```

L'installation:
1. Vérifie les prérequis (Docker, GPU, drivers)
2. Installe NVIDIA Container Toolkit si nécessaire
3. Démarre les services Docker
4. Télécharge les modèles IA (~5GB)

## 📁 Structure du projet

```
devops-rag/
├── docker-compose.yml      # Configuration des services
├── install.sh              # Script d'installation
├── README.md               # Ce fichier
├── config/
│   └── system-prompt.md    # Prompt système pour l'assistant
├── data/                   # Données persistantes (généré)
│   ├── ollama/             # Modèles LLM
│   ├── qdrant/             # Base vectorielle
│   └── open-webui/         # Configuration UI
├── docs/                   # 📄 VOTRE DOCUMENTATION ICI
│   ├── infrastructure/
│   ├── conventions/
│   ├── exigences/
│   └── ...
└── scripts/
    ├── ingest.sh           # Script d'ingestion simple
    └── ingest_api.py       # Ingestion avancée via API
```

## 🎯 Utilisation

### 1. Accéder à l'interface

Ouvrez [http://localhost:3000](http://localhost:3000) dans votre navigateur.

### 2. Configuration initiale

1. **Créer un compte** administrateur
2. **Sélectionner le modèle**: Settings → Models → `qwen2.5-coder:7b-instruct`
3. **Configurer le system prompt**: Copiez le contenu de `config/system-prompt.md`

### 3. Ajouter votre documentation

**Méthode simple** (via l'interface):
1. Allez dans Settings → Documents
2. Cliquez sur "+" pour uploader vos fichiers
3. Glissez-déposez depuis le dossier `docs/`

**Méthode avancée** (via script):
```bash
# Placer vos fichiers dans ./docs/
cp -r /chemin/vers/votre/documentation/* docs/

# Installer les dépendances Python (une seule fois)
pip install langchain langchain-community langchain-qdrant qdrant-client

# Lancer l'ingestion
python scripts/ingest_api.py

# Forcer la réindexation complète
python scripts/ingest_api.py --force
```

### 4. Poser des questions

Dans l'interface de chat, activez le RAG en cliquant sur l'icône 📎 et sélectionnez vos documents, puis posez vos questions:

- "Comment déployer l'application selon notre architecture?"
- "Montre-moi un exemple de pipeline CI/CD conforme à nos conventions"
- "Quelles sont les exigences pour le monitoring?"

## 🔧 Services disponibles

| Service | URL | Description |
|---------|-----|-------------|
| Open WebUI | http://localhost:3000 | Interface de chat |
| Ollama API | http://localhost:11434 | API LLM |
| Qdrant | http://localhost:6333/dashboard | Base vectorielle |

## 📊 Commandes utiles

```bash
# Voir les logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f ollama

# Redémarrer les services
docker compose restart

# Arrêter les services
docker compose down

# Arrêter et supprimer les données
docker compose down -v

# Voir l'utilisation GPU
watch -n 1 nvidia-smi

# Lister les modèles Ollama installés
docker exec ollama ollama list

# Télécharger un nouveau modèle
docker exec ollama ollama pull <nom-du-modele>

# Tester le modèle en CLI
docker exec -it ollama ollama run qwen2.5-coder:7b-instruct
```

## 🔄 Mise à jour de la documentation

Quand vous modifiez vos fichiers de documentation:

```bash
# Le script détecte automatiquement les fichiers modifiés
python scripts/ingest_api.py
```

Seuls les fichiers modifiés seront réindexés.

## 📚 Formats de fichiers supportés

| Catégorie | Extensions |
|-----------|------------|
| Documentation | `.md`, `.txt`, `.html` |
| Configuration | `.yaml`, `.yml`, `.json`, `.toml`, `.ini` |
| Infrastructure | `.tf`, `.hcl`, `Dockerfile`, `docker-compose.yml` |
| Scripts | `.sh`, `.bash`, `.py`, `Makefile`, `Jenkinsfile` |
| CI/CD | `.gitlab-ci.yml`, `.github/workflows/*.yml` |
| Code | `.py`, `.go`, `.js`, `.ts`, `.java`, `.rs` |

## ⚡ Optimisation pour RTX 3080

La configuration est optimisée pour 10GB de VRAM:

- **Modèle principal**: `qwen2.5-coder:7b-instruct` (~5GB VRAM)
- **1 modèle chargé** à la fois en mémoire
- **2 requêtes parallèles** maximum

Pour tester le modèle 14B (à la limite):
```bash
docker exec ollama ollama pull qwen2.5-coder:14b-instruct-q4_K_M
```

## 🔒 Sécurité

- ✅ 100% local - aucune donnée ne quitte votre machine
- ✅ Pas de connexion internet requise après installation
- ⚠️ Par défaut, l'inscription est ouverte - désactivez-la après création du compte admin

Pour désactiver l'inscription:
```yaml
# Dans docker-compose.yml, changez:
- ENABLE_SIGNUP=false
```

## 🐛 Dépannage

### Le GPU n'est pas détecté

```bash
# Vérifier les drivers
nvidia-smi

# Vérifier Docker + GPU
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi

# Redémarrer Docker
sudo systemctl restart docker
```

### Ollama est lent au premier démarrage

Normal - le modèle doit être chargé en VRAM. Les requêtes suivantes seront rapides.

### Erreur "out of memory"

Le modèle est trop gros. Utilisez un modèle plus petit:
```bash
docker exec ollama ollama pull qwen2.5-coder:3b-instruct
```

### Open WebUI ne démarre pas

Vérifiez que Ollama est bien démarré:
```bash
docker compose logs ollama
curl http://localhost:11434/
```

## 📝 Personnalisation

### Changer le modèle par défaut

Modifiez `docker-compose.yml`:
```yaml
environment:
  - DEFAULT_MODELS=qwen2.5-coder:14b-instruct-q4_K_M
```

### Ajuster le chunking

Modifiez les paramètres dans `scripts/ingest_api.py`:
```python
CHUNK_CONFIG = {
    "md": {"chunk_size": 1000, "chunk_overlap": 150, ...},
    ...
}
```

## 📄 Licence

Ce projet utilise des composants open-source:
- [Ollama](https://ollama.ai/) - MIT License
- [Open WebUI](https://github.com/open-webui/open-webui) - MIT License
- [Qdrant](https://qdrant.tech/) - Apache 2.0
- [Qwen 2.5 Coder](https://huggingface.co/Qwen) - Apache 2.0
