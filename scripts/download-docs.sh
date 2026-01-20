#!/bin/bash
#===============================================================================
# Téléchargement des documentations DevOps officielles
# Pour enrichir la base de connaissances RAG
#===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs/references"

echo "=================================================="
echo "  Téléchargement des documentations DevOps"
echo "=================================================="
echo ""

# Créer le dossier de destination
mkdir -p "$DOCS_DIR"
cd "$DOCS_DIR"

#-------------------------------------------------------------------------------
# Fonction utilitaire
#-------------------------------------------------------------------------------
# Disable interactive prompts for Git (prevents hanging on missing repos)
export GIT_TERMINAL_PROMPT=0

download_file() {
    local url="$1"
    local dest="$2"
    local name="$3"
    
    mkdir -p "$(dirname "$dest")"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo "  ✓ $name"
    else
        echo "  ✗ $name (échec)"
    fi
}

clone_repo() {
    local repo="$1"
    local dest="$2"
    local name="$3"
    local subdir="${4:-}"
    
    if [ -d "$dest" ]; then
        echo "  ⏭ $name (déjà présent)"
        return
    fi
    
    echo "  ⏳ $name..."
    # Clone with filter to minimize size (blobless clone)
    if git clone --depth 1 --filter=blob:none --sparse "$repo" "$dest" 2>/dev/null; then
        if [ -n "$subdir" ]; then
            cd "$dest"
            git sparse-checkout set "$subdir" 2>/dev/null
            cd "$DOCS_DIR"
        fi
        echo "  ✓ $name"
    else
        # If failure, try again without sparse just in case, but keep quiet
        echo "  ✗ $name (échec)"
        rm -rf "$dest"
    fi
}


#-------------------------------------------------------------------------------
# 1. Docker
#-------------------------------------------------------------------------------
echo ""
echo "📦 Docker..."
mkdir -p docker

# Docker Documentation (Full)
clone_repo \
    "https://github.com/docker/docs.git" \
    "docker/docs" \
    "Docker Documentation" \
    "content"

#-------------------------------------------------------------------------------
# 2. Kubernetes
#-------------------------------------------------------------------------------
echo ""
echo "☸️  Kubernetes..."
mkdir -p kubernetes

# Kubernetes Documentation (Full)
clone_repo \
    "https://github.com/kubernetes/website.git" \
    "kubernetes/docs" \
    "Kubernetes Documentation" \
    "content/en/docs"

#-------------------------------------------------------------------------------
# 3. Terraform
#-------------------------------------------------------------------------------
echo ""
echo "🏗️  Terraform..."
mkdir -p terraform

# Terraform Database (Website Content)
clone_repo \
    "https://github.com/hashicorp/terraform-website.git" \
    "terraform/docs" \
    "Terraform Documentation" \
    "content"

#-------------------------------------------------------------------------------
# 4. Ansible
#-------------------------------------------------------------------------------
echo ""
echo "🔧 Ansible..."
mkdir -p ansible

# Ansible Documentation (Official)
clone_repo \
    "https://github.com/ansible/ansible-documentation.git" \
    "ansible/docs" \
    "Ansible Documentation"

#-------------------------------------------------------------------------------
# 5. GitHub Actions
#-------------------------------------------------------------------------------
echo ""
echo "🐙 GitHub Actions..."
mkdir -p github-actions

cat > github-actions/best-practices.md << 'EOF'
# GitHub Actions Best Practices

## Structure de workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker image
        run: docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .
```

## Secrets

```yaml
steps:
  - name: Login to Registry
    uses: docker/login-action@v3
    with:
      registry: ${{ env.REGISTRY }}
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}
```

## Cache

```yaml
- name: Cache dependencies
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

## Matrix builds

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, macos-latest]
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

## Conditions

```yaml
- name: Deploy to production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: ./deploy.sh
```

## Réutilisation avec composite actions

```yaml
# .github/actions/setup-env/action.yml
name: Setup Environment
runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    - run: npm ci
      shell: bash
```

## Sécurité

- Utiliser des SHA complets pour les actions tierces
- Limiter les permissions du GITHUB_TOKEN
- Ne jamais logger de secrets

```yaml
permissions:
  contents: read
  packages: write
```
EOF
echo "  ✓ GitHub Actions Best Practices"

#-------------------------------------------------------------------------------
# 6. GitLab CI
#-------------------------------------------------------------------------------
echo ""
echo "🦊 GitLab CI..."
mkdir -p gitlab-ci

# GitLab Documentation (Definitive Reference)
clone_repo \
    "https://github.com/gitlabhq/gitlab.git" \
    "gitlab/docs" \
    "GitLab Documentation" \
    "doc"

#-------------------------------------------------------------------------------
# 7. Python
#-------------------------------------------------------------------------------
echo ""
echo "🐍 Python..."
mkdir -p python

# Python CPython Documentation
clone_repo \
    "https://github.com/python/cpython.git" \
    "python/docs" \
    "Python (CPython) Documentation" \
    "Doc"

#-------------------------------------------------------------------------------
# 8. Bash/Shell
#-------------------------------------------------------------------------------
echo ""
echo "🐚 Bash/Shell..."
mkdir -p bash

# Bash Community Documentation
clone_repo \
    "https://github.com/dylanaraps/pure-bash-bible.git" \
    "bash/docs" \
    "Pure Bash Bible"

#-------------------------------------------------------------------------------
# 9. YAML
#-------------------------------------------------------------------------------
echo ""
echo "📝 YAML..."
mkdir -p yaml

# YAML Official Spec
clone_repo \
    "https://github.com/yaml/yaml-spec.git" \
    "yaml/spec" \
    "YAML Specification"

#-------------------------------------------------------------------------------
# 10. Microsoft
#-------------------------------------------------------------------------------
echo ""
echo "☁️  Microsoft Azure & DevOps..."
mkdir -p microsoft

echo "  🔍 (Microsoft docs skipped here - moved to PowerShell & Azure sections below)"

#-------------------------------------------------------------------------------
# 11. PowerShell
#-------------------------------------------------------------------------------
echo ""
echo "⚡ PowerShell..."
mkdir -p powershell

# PowerShell Documentation (Full)
clone_repo \
    "https://github.com/MicrosoftDocs/PowerShell-Docs.git" \
    "powershell/docs" \
    "PowerShell Documentation" \
    "reference"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 12. Ansible (Cleaned up)
#-------------------------------------------------------------------------------
# Note: Ansible official docs are now cloned in Section 4.


#-------------------------------------------------------------------------------
# 13. Trend Micro (Technical Automation Specs)
#-------------------------------------------------------------------------------
echo ""
echo "🛡️  Trend Micro Automation Specs (Terraform & SDKs)..."
mkdir -p trendmicro

# Terraform Provider: Conformity
# Defines resources for Cloud One Conformity (rules, settings)
clone_repo \
    "https://github.com/trendmicro/terraform-provider-conformity.git" \
    "trendmicro/terraform-conformity" \
    "Terraform Provider: Conformity" \
    "docs"

# Terraform Provider: Vision One
# Defines resources for Vision One Endpoint/XDR
clone_repo \
    "https://github.com/trendmicro/terraform-provider-vision-one.git" \
    "trendmicro/terraform-vision-one" \
    "Terraform Provider: Vision One" \
    "docs"

# Deep Security SDK Samples
# Contains the best practical reference for API usage (Python/Java/Go)
clone_repo \
    "https://github.com/deep-security/automation-center-sdk-samples.git" \
    "trendmicro/sdk-samples" \
    "Deep Security SDK Samples"

#-------------------------------------------------------------------------------
# 14. VMware (Technical Automation Specs)
#-------------------------------------------------------------------------------
echo ""
echo "🖥️  VMware Automation Specs (Terraform & PowerCLI)..."
mkdir -p vmware

# Terraform Provider: vSphere
# The DEFINITIVE reference for Infrastructure as Code (VMs, Networks, Datastores)
clone_repo \
    "https://github.com/hashicorp/terraform-provider-vsphere.git" \
    "vmware/terraform-vsphere" \
    "Terraform Provider: vSphere" \
    "docs"

# vSphere Automation SDK (Python)
# Source of truth for REST API bindings and methods
clone_repo \
    "https://github.com/vmware/vsphere-automation-sdk-python.git" \
    "vmware/vsphere-sdk-python" \
    "vSphere Automation SDK (Python)" \
    "docs"

# PowerCLI Example Scripts
# Real-world automation examples
clone_repo \
    "https://github.com/vmware/PowerCLI-Example-Scripts.git" \
    "vmware/powercli-examples" \
    "PowerCLI Example Scripts"

#-------------------------------------------------------------------------------
# 15. Comprehensive Offline Documentation
#-------------------------------------------------------------------------------
echo ""
echo "🌍 Comprehensive Offline Documentation (RAG Sources)..."
mkdir -p offline

# 13.1 tldr-pages (Community Cheatsheets)
# ~2500 pages of concise CLI examples
clone_repo \
    "https://github.com/tldr-pages/tldr.git" \
    "offline/tldr" \
    "tldr-pages (CLI Cheatsheets)" \
    "pages"

# 13.2 MDN Web Docs (Mozilla)
# The bible of Web Development (HTML/CSS/JS)
# We sparse checkout 'files/en-us' to get only English docs and avoid history/metadata
clone_repo \
    "https://github.com/mdn/content.git" \
    "offline/mdn" \
    "MDN Web Docs (en-us)" \
    "files/en-us"

# Azure Automation (Terraform Provider AzureRM)
# Definitive specs for Azure resources
clone_repo \
    "https://github.com/hashicorp/terraform-provider-azurerm.git" \
    "offline/azure-automation" \
    "Terraform Provider: AzureRM" \
    "website/docs"

# Azure Architecture Center (Already added, keeping)
clone_repo \
    "https://github.com/MicrosoftDocs/architecture-center.git" \
    "offline/azure-architecture" \
    "Azure Architecture Center" \
    "docs"

# Jinja2 Documentation
clone_repo \
    "https://github.com/pallets/jinja.git" \
    "offline/jinja2" \
    "Jinja2 Documentation" \
    "docs"

#-------------------------------------------------------------------------------
# 16. Git
#-------------------------------------------------------------------------------
echo ""
echo "📚 Git..."
mkdir -p git

# Pro Git Book (Full Reference)
clone_repo \
    "https://github.com/progit/progit2.git" \
    "git/progit" \
    "Pro Git Book"

#-------------------------------------------------------------------------------
# 17. Microsoft Enterprise (Identity & Exchange)
#-------------------------------------------------------------------------------
echo ""
echo "🏢 Microsoft Enterprise (AD, Exchange, Entra)..."
mkdir -p microsoft/enterprise

# Active Directory Domain Services (AD DS)
clone_repo \
    "https://github.com/MicrosoftDocs/windowsserverdocs.git" \
    "microsoft/enterprise/active-directory" \
    "Active Directory Documentation" \
    "WindowsServerDocs/identity"

# Exchange Server
# REPLACED: OfficeDocs-Exchange (404) -> office-developer-exchange-docs
clone_repo \
    "https://github.com/MicrosoftDocs/office-developer-exchange-docs.git" \
    "microsoft/enterprise/exchange" \
    "Exchange Server Documentation" \
    "docs/exchange-web-services"

# Microsoft Entra (Azure AD)
clone_repo \
    "https://github.com/MicrosoftDocs/entra-docs.git" \
    "microsoft/enterprise/entra" \
    "Microsoft Entra (Azure AD) Documentation" \
    "docs"

#-------------------------------------------------------------------------------
# 18. Security & Compliance (CIS / ANSSI / Hardening)
#-------------------------------------------------------------------------------
echo ""
echo "🔐 Security & Compliance (CIS, ANSSI, Hardening)..."
mkdir -p security

# Global Hardening Guide Index
clone_repo \
    "https://github.com/decalage2/awesome-security-hardening.git" \
    "security/guides/awesome-hardening" \
    "Awesome Security Hardening Index"

# ANSSI Linux Hardening (Wiki)
# REPLACED: xanhacks (Missing) -> OWASP CheatSheetSeries (Linux)
clone_repo \
    "https://github.com/OWASP/CheatSheetSeries.git" \
    "security/guides/owasp-cheatsheets" \
    "OWASP CheatSheetSeries (Linux Hardening)" \
    "cheatsheets"

# CIS Automation - Linux (Ansible Collection)
clone_repo \
    "https://github.com/dev-sec/ansible-collection-hardening.git" \
    "security/automation/linux-cis-ansible" \
    "CIS Linux Hardening (Ansible Collection)"

# CIS Automation - Windows (Ansible Lockdown)
clone_repo \
    "https://github.com/ansible-lockdown/Windows-2019-CIS.git" \
    "security/automation/windows-cis-lockdown" \
    "CIS Windows Server 2019 Hardening"

#-------------------------------------------------------------------------------
# 19. Advanced Security Granularity
#-------------------------------------------------------------------------------
echo ""
echo "🛡️  Advanced Security Granularity (Audit, Integrity, Logs)..."
mkdir -p security/advanced

# Linux Auditing (Official Userspace Tools)
clone_repo \
    "https://github.com/linux-audit/audit-userspace.git" \
    "security/advanced/linux-audit" \
    "Linux Audit Documentation"

# Linux Integrity (AIDE - Ansible Role)
clone_repo \
    "https://github.com/linux-system-roles/aide.git" \
    "security/advanced/linux-integrity-aide" \
    "Linux Integrity (AIDE) Ansible Role"

# Windows Logging (ANSSI Guide)
clone_repo \
    "https://github.com/ANSSI-FR/guide-journalisation-microsoft.git" \
    "security/advanced/windows-logging-anssi" \
    "Windows Logging Guide (ANSSI)"

# Windows Defender Hardening
clone_repo \
    "https://github.com/Defenestrator/Defenestrator.git" \
    "security/advanced/windows-defender-hardening" \
    "Windows Defender Hardening Scripts"

#-------------------------------------------------------------------------------
# 20. Observability Pack (Monitoring & Logs)
#-------------------------------------------------------------------------------
echo ""
echo "🔭 Observability (Prometheus, Grafana, Loki, OTel)..."
mkdir -p observability

# Prometheus (Official Docs)
clone_repo \
    "https://github.com/prometheus/docs.git" \
    "observability/prometheus" \
    "Prometheus Documentation"

# Grafana (Website Docs)
clone_repo \
    "https://github.com/grafana/grafana.git" \
    "observability/grafana" \
    "Grafana Documentation" \
    "docs"

# Loki (Log Aggregation)
clone_repo \
    "https://github.com/grafana/loki.git" \
    "observability/loki" \
    "Loki Documentation" \
    "docs"

# OpenTelemetry (Standard)
clone_repo \
    "https://github.com/open-telemetry/opentelemetry.io.git" \
    "observability/opentelemetry" \
    "OpenTelemetry Documentation" \
    "content"

#-------------------------------------------------------------------------------
# 21. Infrastructure Upgrade Pack (Vault, Nginx, Data)
#-------------------------------------------------------------------------------
echo ""
echo "🏗️  Infrastructure Upgrade (Vault, Nginx, DBs)..."
mkdir -p infrastructure

# HashiCorp Vault (Secrets Management)
clone_repo \
    "https://github.com/hashicorp/vault.git" \
    "infrastructure/vault" \
    "Vault Documentation" \
    "website/content"

# NGINX (Official Documentation)
clone_repo \
    "https://github.com/nginx/documentation.git" \
    "infrastructure/nginx" \
    "NGINX Documentation"

# Traefik (Cloud Native Proxy)
clone_repo \
    "https://github.com/traefik/traefik.git" \
    "infrastructure/traefik" \
    "Traefik Documentation" \
    "docs"

# PostgreSQL (Markdown Version)
clone_repo \
    "https://github.com/wware/postgres-md.git" \
    "infrastructure/postgresql" \
    "PostgreSQL Documentation (Markdown)"

# Redis (Official Docs)
clone_repo \
    "https://github.com/redis/redis-doc.git" \
    "infrastructure/redis" \
    "Redis Documentation"

#-------------------------------------------------------------------------------
# 22. Modern Cloud Languages Pack (The Code of Infra)
#-------------------------------------------------------------------------------
echo ""
echo "🚀 Modern Cloud Languages (Go, Rust)..."
mkdir -p languages

# Go (Golang) - Website Content
clone_repo \
    "https://github.com/golang/website.git" \
    "languages/go" \
    "Go (Golang) Documentation"

# Rust (The Book)
clone_repo \
    "https://github.com/rust-lang/book.git" \
    "languages/rust" \
    "Rust Programming Language (The Book)"

#-------------------------------------------------------------------------------
# 23. GitOps & CI/CD Pack (Modern Deployment)
#-------------------------------------------------------------------------------
echo ""
echo "🔄 GitOps & CI/CD (ArgoCD, Helm, Jenkins)..."
mkdir -p gitops

# ArgoCD (GitOps Standard)
clone_repo \
    "https://github.com/argoproj/argo-cd.git" \
    "gitops/argocd" \
    "ArgoCD Documentation" \
    "docs"

# Helm (Kubernetes Package Manager)
clone_repo \
    "https://github.com/helm/helm-www.git" \
    "gitops/helm" \
    "Helm Documentation" \
    "content"

# Jenkins (CI/CD Standard)
clone_repo \
    "https://github.com/jenkinsci/jenkins.git" \
    "gitops/jenkins" \
    "Jenkins Documentation" \
    "core/src/main/resources/hudson/model"


#-------------------------------------------------------------------------------
# 24. Data Streaming Pack (Event Architecture)
#-------------------------------------------------------------------------------
echo ""
echo "🌊 Data Streaming (Kafka, RabbitMQ)..."
mkdir -p streaming

# Apache Kafka
clone_repo \
    "https://github.com/apache/kafka-site.git" \
    "streaming/kafka" \
    "Apache Kafka Documentation"

# RabbitMQ
clone_repo \
    "https://github.com/rabbitmq/rabbitmq-website.git" \
    "streaming/rabbitmq" \
    "RabbitMQ Documentation"




#-------------------------------------------------------------------------------
# Résumé
#-------------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "  ✅ Téléchargement terminé !"
echo "=================================================="
echo ""
echo "Documentation téléchargée dans: $DOCS_DIR"
echo ""
echo "Contenu:"
find "$DOCS_DIR" -name "*.md" | wc -l
echo " fichiers Markdown"
echo ""
echo "Prochaine étape:"
echo "  Uploadez ces fichiers dans Open WebUI → Settings → Documents"
echo ""
