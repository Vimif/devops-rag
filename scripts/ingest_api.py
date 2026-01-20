#!/usr/bin/env python3
"""
Script d'ingestion automatique de documentation via LangChain + Qdrant.
Utilisez ce script pour une ingestion programmatique avancée avec chunking personnalisé.

Usage:
    pip install langchain langchain-community langchain-qdrant qdrant-client
    python scripts/ingest_api.py

Ce script:
    - Scanne le dossier ./docs/
    - Applique un chunking intelligent par type de fichier
    - Indexe dans Qdrant avec les embeddings d'Ollama
"""

import os
import hashlib
import json
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

# LangChain imports
from langchain_community.document_loaders import (
    TextLoader,
    UnstructuredMarkdownLoader,
)
from langchain.text_splitter import (
    RecursiveCharacterTextSplitter,
    Language,
)
from langchain_community.embeddings import OllamaEmbeddings
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

#===============================================================================
# Configuration
#===============================================================================

DOCS_DIR = Path(__file__).parent.parent / "docs"
QDRANT_URL = "http://localhost:6333"
OLLAMA_URL = "http://localhost:11434"
COLLECTION_NAME = "devops_docs"
EMBEDDING_MODEL = "nomic-embed-text"
METADATA_FILE = Path(__file__).parent.parent / "data" / "ingestion_metadata.json"

# Configuration du chunking par type de fichier
CHUNK_CONFIG = {
    # Documentation
    "md": {"chunk_size": 800, "chunk_overlap": 100, "language": None},
    "txt": {"chunk_size": 800, "chunk_overlap": 100, "language": None},
    
    # Configuration
    "yaml": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    "yml": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    "json": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    "toml": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    
    # Infrastructure as Code
    "tf": {"chunk_size": 600, "chunk_overlap": 50, "language": None},
    "hcl": {"chunk_size": 600, "chunk_overlap": 50, "language": None},
    
    # Scripts et Code
    "py": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.PYTHON},
    "sh": {"chunk_size": 400, "chunk_overlap": 50, "language": None},
    "bash": {"chunk_size": 400, "chunk_overlap": 50, "language": None},
    "go": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.GO},
    "js": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.JS},
    "ts": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.TS},
    "java": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.JAVA},
    "rs": {"chunk_size": 400, "chunk_overlap": 50, "language": Language.RUST},
    
    # Fichiers spéciaux (traités comme texte)
    "dockerfile": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    "makefile": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
    "jenkinsfile": {"chunk_size": 500, "chunk_overlap": 50, "language": None},
}

DEFAULT_CHUNK_CONFIG = {"chunk_size": 600, "chunk_overlap": 50, "language": None}

#===============================================================================
# Fonctions utilitaires
#===============================================================================

def get_file_hash(filepath: Path) -> str:
    """Calcule le hash SHA256 d'un fichier."""
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def load_metadata() -> Dict[str, Any]:
    """Charge les métadonnées d'ingestion précédentes."""
    if METADATA_FILE.exists():
        with open(METADATA_FILE, "r") as f:
            return json.load(f)
    return {"files": {}, "last_ingestion": None}


def save_metadata(metadata: Dict[str, Any]):
    """Sauvegarde les métadonnées d'ingestion."""
    METADATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(METADATA_FILE, "w") as f:
        json.dump(metadata, f, indent=2)


def get_file_extension(filepath: Path) -> str:
    """Retourne l'extension normalisée d'un fichier."""
    name = filepath.name.lower()
    
    # Fichiers spéciaux sans extension
    if name.startswith("dockerfile"):
        return "dockerfile"
    if name == "makefile":
        return "makefile"
    if name == "jenkinsfile":
        return "jenkinsfile"
    
    # Extension normale
    ext = filepath.suffix.lower().lstrip(".")
    return ext if ext else "txt"


def get_splitter_for_file(filepath: Path) -> RecursiveCharacterTextSplitter:
    """Retourne le text splitter approprié pour un fichier."""
    ext = get_file_extension(filepath)
    config = CHUNK_CONFIG.get(ext, DEFAULT_CHUNK_CONFIG)
    
    if config["language"]:
        return RecursiveCharacterTextSplitter.from_language(
            language=config["language"],
            chunk_size=config["chunk_size"],
            chunk_overlap=config["chunk_overlap"],
        )
    else:
        return RecursiveCharacterTextSplitter(
            chunk_size=config["chunk_size"],
            chunk_overlap=config["chunk_overlap"],
            separators=["\n\n", "\n", " ", ""],
        )


def scan_docs_directory() -> List[Path]:
    """Scanne le dossier docs et retourne la liste des fichiers supportés."""
    supported_extensions = set(CHUNK_CONFIG.keys()) | {
        "txt", "xml", "html", "css", "sql", "groovy", "ini", "cfg", "conf"
    }
    
    files = []
    for filepath in DOCS_DIR.rglob("*"):
        if filepath.is_file():
            ext = get_file_extension(filepath)
            name = filepath.name.lower()
            
            # Ignorer les fichiers cachés et temporaires
            if name.startswith(".") or name.endswith("~"):
                continue
            
            # Vérifier l'extension ou les noms spéciaux
            if ext in supported_extensions or name in ["dockerfile", "makefile", "jenkinsfile"]:
                files.append(filepath)
    
    return sorted(files)


#===============================================================================
# Fonction principale d'ingestion
#===============================================================================

def ingest_documents(force: bool = False):
    """
    Ingère les documents dans Qdrant.
    
    Args:
        force: Si True, réindexe tous les fichiers même s'ils n'ont pas changé.
    """
    print("=" * 60)
    print("  Ingestion de la documentation DevOps")
    print("=" * 60)
    print()
    
    # Vérifier le dossier docs
    if not DOCS_DIR.exists():
        DOCS_DIR.mkdir(parents=True)
        print(f"📁 Dossier créé: {DOCS_DIR}")
        print("   Placez vos fichiers de documentation dedans et relancez le script.")
        return
    
    # Scanner les fichiers
    files = scan_docs_directory()
    if not files:
        print(f"⚠️  Aucun fichier trouvé dans {DOCS_DIR}")
        return
    
    print(f"📄 {len(files)} fichier(s) trouvé(s)")
    
    # Charger les métadonnées
    metadata = load_metadata()
    
    # Déterminer les fichiers à indexer
    files_to_index = []
    for filepath in files:
        file_key = str(filepath.relative_to(DOCS_DIR))
        current_hash = get_file_hash(filepath)
        
        if force:
            files_to_index.append(filepath)
        elif file_key not in metadata["files"]:
            files_to_index.append(filepath)
        elif metadata["files"][file_key]["hash"] != current_hash:
            files_to_index.append(filepath)
    
    if not files_to_index:
        print("✓ Tous les fichiers sont déjà indexés et à jour.")
        return
    
    print(f"📥 {len(files_to_index)} fichier(s) à indexer")
    print()
    
    # Initialiser les embeddings
    print("🔧 Initialisation des embeddings...")
    embeddings = OllamaEmbeddings(
        model=EMBEDDING_MODEL,
        base_url=OLLAMA_URL,
    )
    
    # Initialiser Qdrant
    print("🔧 Connexion à Qdrant...")
    client = QdrantClient(url=QDRANT_URL)
    
    # Créer la collection si elle n'existe pas
    collections = [c.name for c in client.get_collections().collections]
    if COLLECTION_NAME not in collections:
        print(f"📦 Création de la collection '{COLLECTION_NAME}'...")
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(
                size=768,  # Dimension de nomic-embed-text
                distance=Distance.COSINE,
            ),
        )
    
    # Traiter chaque fichier
    all_documents = []
    for filepath in files_to_index:
        relative_path = filepath.relative_to(DOCS_DIR)
        print(f"  📄 {relative_path}")
        
        try:
            # Charger le fichier
            loader = TextLoader(str(filepath), encoding="utf-8")
            documents = loader.load()
            
            # Chunking
            splitter = get_splitter_for_file(filepath)
            chunks = splitter.split_documents(documents)
            
            # Ajouter les métadonnées
            for i, chunk in enumerate(chunks):
                chunk.metadata.update({
                    "source": str(relative_path),
                    "file_type": get_file_extension(filepath),
                    "chunk_index": i,
                    "total_chunks": len(chunks),
                    "ingested_at": datetime.now().isoformat(),
                })
            
            all_documents.extend(chunks)
            
            # Mettre à jour les métadonnées
            metadata["files"][str(relative_path)] = {
                "hash": get_file_hash(filepath),
                "chunks": len(chunks),
                "indexed_at": datetime.now().isoformat(),
            }
            
        except Exception as e:
            print(f"    ❌ Erreur: {e}")
            continue
    
    # Indexer dans Qdrant
    if all_documents:
        print()
        print(f"📤 Indexation de {len(all_documents)} chunks dans Qdrant...")
        
        QdrantVectorStore.from_documents(
            documents=all_documents,
            embedding=embeddings,
            url=QDRANT_URL,
            collection_name=COLLECTION_NAME,
            force_recreate=force,  # Recréer si force=True
        )
        
        print("✓ Indexation terminée")
    
    # Sauvegarder les métadonnées
    metadata["last_ingestion"] = datetime.now().isoformat()
    save_metadata(metadata)
    
    print()
    print("=" * 60)
    print("  ✅ Ingestion terminée")
    print("=" * 60)
    print()
    print(f"  Fichiers indexés: {len(files_to_index)}")
    print(f"  Chunks créés: {len(all_documents)}")
    print(f"  Collection: {COLLECTION_NAME}")
    print()


#===============================================================================
# Point d'entrée
#===============================================================================

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Ingestion de documentation DevOps")
    parser.add_argument(
        "--force", "-f",
        action="store_true",
        help="Forcer la réindexation de tous les fichiers"
    )
    args = parser.parse_args()
    
    ingest_documents(force=args.force)
