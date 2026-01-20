#!/bin/bash
#===============================================================================
#
#  ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗    ██████╗  █████╗  ██████╗
#  ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝    ██╔══██╗██╔══██╗██╔════╝
#  ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗    ██████╔╝███████║██║  ███╗
#  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║    ██╔══██╗██╔══██║██║   ██║
#  ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║    ██║  ██║██║  ██║╚██████╔╝
#  ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
#  DOCUMENTATION ULTRA-COMPLÈTE POUR ENVIRONNEMENT AIR-GAPPED
#  Version: 2.0 - Maximum Coverage
#
#===============================================================================
#
#  CONTENU ESTIMÉ: 40-60 Go
#  TEMPS ESTIMÉ: 2-5 heures (selon connexion)
#
#  SECTIONS:
#    1.  Ansible (7 versions + 60+ collections + 50+ roles)
#    2.  Terraform (core + 40+ providers)
#    3.  Docker & Containers
#    4.  Kubernetes (complet)
#    5.  CI/CD (GitLab, Jenkins, GitHub Actions, etc.)
#    6.  Python (100+ bibliothèques)
#    7.  Bash/Shell (complet)
#    8.  PowerShell (complet)
#    9.  Go, Rust
#    10. Réseau (protocoles, outils)
#    11. Bases de données (toutes)
#    12. Sécurité (exhaustif)
#    13. Monitoring (complet)
#    14. Infrastructure (HashiCorp, web servers, etc.)
#    15. Linux (kernel docs, systemd, etc.)
#    16. Windows Server
#    17. VMware & Virtualisation
#    18. Références & Cheatsheets
#
#===============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs"
LOG_FILE="$SCRIPT_DIR/download.log"
FAILED_FILE="$SCRIPT_DIR/failed.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

#===============================================================================
# FONCTIONS
#===============================================================================

banner() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
}

section() {
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│ $1${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
}

export GIT_TERMINAL_PROMPT=0

clone_full() {
    local repo="$1"
    local dest="$2"
    local name="$3"
    
    if [ -d "$dest" ]; then
        echo -e "  ${YELLOW}⏭${NC} $name (existe)"
        return 0
    fi
    
    echo -e "  ${CYAN}⏳${NC} $name..."
    if timeout 300 git clone --depth 1 "$repo" "$dest" 2>>"$LOG_FILE"; then
        echo -e "  ${GREEN}✓${NC} $name" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name" | tee -a "$FAILED_FILE"
        rm -rf "$dest" 2>/dev/null
        return 1
    fi
}

clone_sparse() {
    local repo="$1"
    local dest="$2"
    local name="$3"
    local subdirs="$4"
    
    if [ -d "$dest" ]; then
        echo -e "  ${YELLOW}⏭${NC} $name (existe)"
        return 0
    fi
    
    echo -e "  ${CYAN}⏳${NC} $name..."
    if timeout 300 git clone --depth 1 --filter=blob:none --sparse "$repo" "$dest" 2>>"$LOG_FILE"; then
        cd "$dest"
        git sparse-checkout set $subdirs 2>>"$LOG_FILE" || true
        cd "$DOCS_DIR"
        echo -e "  ${GREEN}✓${NC} $name" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name" | tee -a "$FAILED_FILE"
        rm -rf "$dest" 2>/dev/null
        return 1
    fi
}

clone_branch() {
    local repo="$1"
    local dest="$2"
    local name="$3"
    local branch="$4"
    local subdirs="${5:-}"
    
    if [ -d "$dest" ]; then
        echo -e "  ${YELLOW}⏭${NC} $name (existe)"
        return 0
    fi
    
    echo -e "  ${CYAN}⏳${NC} $name..."
    if timeout 300 git clone --depth 1 --branch "$branch" ${subdirs:+--filter=blob:none --sparse} "$repo" "$dest" 2>>"$LOG_FILE"; then
        if [ -n "$subdirs" ]; then
            cd "$dest"
            git sparse-checkout set $subdirs 2>>"$LOG_FILE" || true
            cd "$DOCS_DIR"
        fi
        echo -e "  ${GREEN}✓${NC} $name" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name ($branch)" | tee -a "$FAILED_FILE"
        rm -rf "$dest" 2>/dev/null
        return 1
    fi
}

#===============================================================================
# DÉMARRAGE
#===============================================================================

clear
echo ""
echo -e "${CYAN}"
cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   DOCUMENTATION DEVOPS ULTRA-COMPLÈTE                                    ║
  ║   Pour environnement Air-Gapped                                          ║
  ║                                                                          ║
  ║   📦 Taille estimée: 40-60 Go                                            ║
  ║   ⏱️  Temps estimé: 2-5 heures                                            ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}⚠️  Ce script va télécharger une quantité MASSIVE de documentation.${NC}"
echo -e "${YELLOW}   Assurez-vous d'avoir suffisamment d'espace disque.${NC}"
echo ""

read -p "Continuer ? (o/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    echo "Annulé."
    exit 0
fi

# Vérifications
command -v git &>/dev/null || { echo "❌ Git requis"; exit 1; }

# Initialisation
mkdir -p "$DOCS_DIR"
cd "$DOCS_DIR"
echo "=== Début: $(date) ===" > "$LOG_FILE"
echo "=== Échecs ===" > "$FAILED_FILE"

START_TIME=$(date +%s)

#===============================================================================
#  SECTION 1: ANSIBLE
#===============================================================================
banner "📚 SECTION 1: ANSIBLE"

section "Ansible Core (6 versions)"
mkdir -p ansible/core

for ver in "stable-2.17" "stable-2.16" "stable-2.15" "stable-2.14" "stable-2.13" "stable-2.12"; do
    v=$(echo $ver | sed 's/stable-//')
    clone_branch "https://github.com/ansible/ansible.git" \
        "ansible/core/v$v" "Ansible $v" "$ver" \
        "docs lib/ansible/modules lib/ansible/plugins lib/ansible/module_utils"
done

section "Documentation Ansible"
clone_full "https://github.com/ansible/ansible-documentation.git" "ansible/docs" "Ansible Docs"
clone_full "https://github.com/ansible/ansible-examples.git" "ansible/examples" "Ansible Examples"

section "Collections Ansible officielles"
mkdir -p ansible/collections/ansible
clone_full "https://github.com/ansible-collections/ansible.posix.git" "ansible/collections/ansible/posix" "ansible.posix"
clone_full "https://github.com/ansible-collections/ansible.windows.git" "ansible/collections/ansible/windows" "ansible.windows"
clone_full "https://github.com/ansible-collections/ansible.netcommon.git" "ansible/collections/ansible/netcommon" "ansible.netcommon"
clone_full "https://github.com/ansible-collections/ansible.utils.git" "ansible/collections/ansible/utils" "ansible.utils"

section "Collections Community - Général"
mkdir -p ansible/collections/community
clone_full "https://github.com/ansible-collections/community.general.git" "ansible/collections/community/general" "community.general"
clone_full "https://github.com/ansible-collections/community.crypto.git" "ansible/collections/community/crypto" "community.crypto"
clone_full "https://github.com/ansible-collections/community.dns.git" "ansible/collections/community/dns" "community.dns"
clone_full "https://github.com/ansible-collections/community.sops.git" "ansible/collections/community/sops" "community.sops"

section "Collections Windows"
mkdir -p ansible/collections/windows
clone_full "https://github.com/ansible-collections/community.windows.git" "ansible/collections/windows/community" "community.windows"
clone_full "https://github.com/ansible-collections/microsoft.ad.git" "ansible/collections/windows/microsoft-ad" "microsoft.ad"
#clone_full "https://github.com/ansible-collections/chocolatey.chocolatey.git" "ansible/collections/windows/chocolatey" "chocolatey"

section "Collections Containers"
mkdir -p ansible/collections/containers
clone_full "https://github.com/ansible-collections/community.docker.git" "ansible/collections/containers/docker" "community.docker"
clone_full "https://github.com/ansible-collections/kubernetes.core.git" "ansible/collections/containers/kubernetes" "kubernetes.core"
clone_full "https://github.com/ansible-collections/community.vmware.git" "ansible/collections/containers/vmware" "community.vmware"
clone_full "https://github.com/ansible-collections/community.libvirt.git" "ansible/collections/containers/libvirt" "community.libvirt"
clone_full "https://github.com/ansible-collections/community.proxmox.git" "ansible/collections/containers/proxmox" "community.proxmox"
clone_full "https://github.com/containers/ansible-podman-collections.git" "ansible/collections/containers/podman" "containers.podman"

section "Collections Databases"
mkdir -p ansible/collections/databases
clone_full "https://github.com/ansible-collections/community.postgresql.git" "ansible/collections/databases/postgresql" "community.postgresql"
clone_full "https://github.com/ansible-collections/community.mysql.git" "ansible/collections/databases/mysql" "community.mysql"
clone_full "https://github.com/ansible-collections/community.mongodb.git" "ansible/collections/databases/mongodb" "community.mongodb"
clone_full "https://github.com/ansible-collections/community.cassandra.git" "ansible/collections/databases/cassandra" "community.cassandra"
clone_full "https://github.com/ansible-collections/community.elastic.git" "ansible/collections/databases/elastic" "community.elastic"
clone_full "https://github.com/ansible-collections/community.rabbitmq.git" "ansible/collections/databases/rabbitmq" "community.rabbitmq"

section "Collections Réseau"
mkdir -p ansible/collections/network
clone_full "https://github.com/ansible-collections/community.network.git" "ansible/collections/network/community" "community.network"
clone_full "https://github.com/ansible-collections/cisco.ios.git" "ansible/collections/network/cisco-ios" "cisco.ios"
clone_full "https://github.com/ansible-collections/cisco.nxos.git" "ansible/collections/network/cisco-nxos" "cisco.nxos"
clone_full "https://github.com/ansible-collections/cisco.asa.git" "ansible/collections/network/cisco-asa" "cisco.asa"
clone_full "https://github.com/ansible-collections/junipernetworks.junos.git" "ansible/collections/network/juniper" "juniper"
clone_full "https://github.com/ansible-collections/arista.eos.git" "ansible/collections/network/arista" "arista.eos"
clone_full "https://github.com/ansible-collections/vyos.vyos.git" "ansible/collections/network/vyos" "vyos"
#clone_full "https://github.com/ansible-collections/f5networks.f5_modules.git" "ansible/collections/network/f5" "f5"
clone_full "https://github.com/pfsensible/core.git" "ansible/collections/network/pfsense" "pfsensible"
clone_full "https://github.com/ansible-collections/community.routeros.git" "ansible/collections/network/routeros" "routeros"

section "Collections Monitoring"
mkdir -p ansible/collections/monitoring
clone_full "https://github.com/ansible-collections/community.grafana.git" "ansible/collections/monitoring/grafana" "community.grafana"
clone_full "https://github.com/ansible-collections/community.zabbix.git" "ansible/collections/monitoring/zabbix" "community.zabbix"
clone_full "https://github.com/prometheus-community/ansible.git" "ansible/collections/monitoring/prometheus" "prometheus"

section "Collections Sécurité & CIS"
mkdir -p ansible/collections/security
clone_full "https://github.com/dev-sec/ansible-collection-hardening.git" "ansible/collections/security/devsec" "devsec.hardening"
clone_full "https://github.com/ansible-collections/community.hashi_vault.git" "ansible/collections/security/vault" "hashi_vault"

mkdir -p ansible/collections/security/cis
clone_full "https://github.com/ansible-lockdown/RHEL7-CIS.git" "ansible/collections/security/cis/rhel7" "RHEL7-CIS"
clone_full "https://github.com/ansible-lockdown/RHEL8-CIS.git" "ansible/collections/security/cis/rhel8" "RHEL8-CIS"
clone_full "https://github.com/ansible-lockdown/RHEL9-CIS.git" "ansible/collections/security/cis/rhel9" "RHEL9-CIS"
clone_full "https://github.com/ansible-lockdown/UBUNTU20-CIS.git" "ansible/collections/security/cis/ubuntu20" "Ubuntu20-CIS"
clone_full "https://github.com/ansible-lockdown/UBUNTU22-CIS.git" "ansible/collections/security/cis/ubuntu22" "Ubuntu22-CIS"
clone_full "https://github.com/ansible-lockdown/Windows-2019-CIS.git" "ansible/collections/security/cis/win2019" "Win2019-CIS"
clone_full "https://github.com/ansible-lockdown/Windows-2022-CIS.git" "ansible/collections/security/cis/win2022" "Win2022-CIS"

section "Collections CI/CD"
mkdir -p ansible/collections/cicd
#clone_full "https://github.com/ansible-collections/community.gitlab.git" "ansible/collections/cicd/gitlab" "community.gitlab"
#clone_full "https://github.com/ansible-collections/community.github.git" "ansible/collections/cicd/github" "community.github"

section "Roles Geerlingguy"
mkdir -p ansible/roles/geerlingguy
for role in docker nginx postgresql mysql redis java jenkins apache php nodejs pip \
            firewall security ntp certbot haproxy elasticsearch kibana logstash \
            memcached rabbitmq gitlab kubernetes; do
    clone_full "https://github.com/geerlingguy/ansible-role-$role.git" \
        "ansible/roles/geerlingguy/$role" "geerlingguy.$role"
done

section "Roles Linux System Roles"
mkdir -p ansible/roles/linux-system-roles
for role in network storage firewall selinux timesync aide crypto_policies logging metrics ssh; do
    clone_full "https://github.com/linux-system-roles/$role.git" \
        "ansible/roles/linux-system-roles/$role" "linux.$role"
done

section "Outils Ansible"
mkdir -p ansible/tools
clone_full "https://github.com/ansible/ansible-lint.git" "ansible/tools/ansible-lint" "ansible-lint"
clone_full "https://github.com/ansible/molecule.git" "ansible/tools/molecule" "molecule"
clone_full "https://github.com/ansible/ansible-navigator.git" "ansible/tools/navigator" "ansible-navigator"
clone_full "https://github.com/ansible/ansible-builder.git" "ansible/tools/builder" "ansible-builder"
clone_full "https://github.com/ansible/awx.git" "ansible/tools/awx" "AWX"
clone_full "https://github.com/ansible-semaphore/semaphore.git" "ansible/tools/semaphore" "Semaphore"

echo ""
echo -e "${GREEN}✅ Section Ansible terminée${NC}"


#===============================================================================
#  SECTION 2: TERRAFORM
#===============================================================================
banner "📚 SECTION 2: TERRAFORM"

section "Terraform Core"
mkdir -p terraform
clone_sparse "https://github.com/hashicorp/terraform.git" "terraform/core" "Terraform Core" "docs website"

section "Providers Virtualisation"
mkdir -p terraform/providers/virtualization
clone_full "https://github.com/hashicorp/terraform-provider-vsphere.git" "terraform/providers/virtualization/vsphere" "vsphere"
clone_full "https://github.com/Telmate/terraform-provider-proxmox.git" "terraform/providers/virtualization/proxmox" "proxmox"
clone_full "https://github.com/dmacvicar/terraform-provider-libvirt.git" "terraform/providers/virtualization/libvirt" "libvirt"
clone_full "https://github.com/taliesins/terraform-provider-hyperv.git" "terraform/providers/virtualization/hyperv" "hyperv"

section "Providers Containers"
mkdir -p terraform/providers/containers
clone_full "https://github.com/kreuzwerker/terraform-provider-docker.git" "terraform/providers/containers/docker" "docker"
clone_full "https://github.com/hashicorp/terraform-provider-kubernetes.git" "terraform/providers/containers/kubernetes" "kubernetes"
clone_full "https://github.com/hashicorp/terraform-provider-helm.git" "terraform/providers/containers/helm" "helm"
clone_full "https://github.com/gavinbunney/terraform-provider-kubectl.git" "terraform/providers/containers/kubectl" "kubectl"

section "Providers HashiCorp"
mkdir -p terraform/providers/hashicorp
clone_full "https://github.com/hashicorp/terraform-provider-vault.git" "terraform/providers/hashicorp/vault" "vault"
clone_full "https://github.com/hashicorp/terraform-provider-consul.git" "terraform/providers/hashicorp/consul" "consul"
clone_full "https://github.com/hashicorp/terraform-provider-nomad.git" "terraform/providers/hashicorp/nomad" "nomad"
clone_full "https://github.com/hashicorp/terraform-provider-boundary.git" "terraform/providers/hashicorp/boundary" "boundary"

section "Providers Utilitaires"
mkdir -p terraform/providers/utility
clone_full "https://github.com/hashicorp/terraform-provider-null.git" "terraform/providers/utility/null" "null"
clone_full "https://github.com/hashicorp/terraform-provider-local.git" "terraform/providers/utility/local" "local"
clone_full "https://github.com/hashicorp/terraform-provider-random.git" "terraform/providers/utility/random" "random"
clone_full "https://github.com/hashicorp/terraform-provider-tls.git" "terraform/providers/utility/tls" "tls"
clone_full "https://github.com/hashicorp/terraform-provider-time.git" "terraform/providers/utility/time" "time"
clone_full "https://github.com/hashicorp/terraform-provider-http.git" "terraform/providers/utility/http" "http"
clone_full "https://github.com/hashicorp/terraform-provider-external.git" "terraform/providers/utility/external" "external"
clone_full "https://github.com/hashicorp/terraform-provider-archive.git" "terraform/providers/utility/archive" "archive"

section "Providers Réseau & DNS"
mkdir -p terraform/providers/network
clone_full "https://github.com/hashicorp/terraform-provider-dns.git" "terraform/providers/network/dns" "dns"
clone_full "https://github.com/infobloxopen/terraform-provider-infoblox.git" "terraform/providers/network/infoblox" "infoblox"
clone_full "https://github.com/PaloAltoNetworks/terraform-provider-panos.git" "terraform/providers/network/panos" "panos"

section "Providers Databases"
mkdir -p terraform/providers/databases
clone_full "https://github.com/cyrilgdn/terraform-provider-postgresql.git" "terraform/providers/databases/postgresql" "postgresql"
clone_full "https://github.com/petoju/terraform-provider-mysql.git" "terraform/providers/databases/mysql" "mysql"
clone_full "https://github.com/elastic/terraform-provider-elasticstack.git" "terraform/providers/databases/elastic" "elastic"

section "Providers CI/CD"
mkdir -p terraform/providers/cicd
clone_full "https://github.com/gitlabhq/terraform-provider-gitlab.git" "terraform/providers/cicd/gitlab" "gitlab"
clone_full "https://github.com/integrations/terraform-provider-github.git" "terraform/providers/cicd/github" "github"
clone_full "https://github.com/argoproj-labs/terraform-provider-argocd.git" "terraform/providers/cicd/argocd" "argocd"

section "Providers Monitoring"
mkdir -p terraform/providers/monitoring
clone_full "https://github.com/grafana/terraform-provider-grafana.git" "terraform/providers/monitoring/grafana" "grafana"

section "Providers Sécurité"
mkdir -p terraform/providers/security
clone_full "https://github.com/hashicorp/terraform-provider-ad.git" "terraform/providers/security/ad" "active-directory"
clone_full "https://github.com/keycloak/terraform-provider-keycloak.git" "terraform/providers/security/keycloak" "keycloak"

section "Providers Ansible"
clone_full "https://github.com/ansible/terraform-provider-ansible.git" "terraform/providers/ansible" "ansible"

section "Outils Terraform"
mkdir -p terraform/tools
clone_full "https://github.com/terraform-docs/terraform-docs.git" "terraform/tools/terraform-docs" "terraform-docs"
clone_full "https://github.com/terraform-linters/tflint.git" "terraform/tools/tflint" "tflint"
clone_full "https://github.com/aquasecurity/tfsec.git" "terraform/tools/tfsec" "tfsec"
clone_full "https://github.com/gruntwork-io/terragrunt.git" "terraform/tools/terragrunt" "terragrunt"
clone_full "https://github.com/infracost/infracost.git" "terraform/tools/infracost" "infracost"
clone_full "https://github.com/bridgecrewio/checkov.git" "terraform/tools/checkov" "checkov"

section "Best Practices Terraform"
clone_full "https://github.com/antonbabenko/terraform-best-practices.git" "terraform/best-practices" "terraform-best-practices"

echo -e "${GREEN}✅ Section Terraform terminée${NC}"

#===============================================================================
#  SECTION 3: CONTAINERS
#===============================================================================
banner "📚 SECTION 3: CONTAINERS"

section "Docker"
mkdir -p containers/docker
clone_sparse "https://github.com/docker/docs.git" "containers/docker/docs" "Docker Docs" "content"
clone_full "https://github.com/docker/compose.git" "containers/docker/compose" "Docker Compose"
clone_full "https://github.com/docker/buildx.git" "containers/docker/buildx" "Docker Buildx"
clone_full "https://github.com/docker/cli.git" "containers/docker/cli" "Docker CLI"
clone_full "https://github.com/docker/docker-bench-security.git" "containers/docker/bench-security" "Docker Bench"
clone_full "https://github.com/wagoodman/dive.git" "containers/docker/dive" "Dive"
clone_full "https://github.com/hadolint/hadolint.git" "containers/docker/hadolint" "Hadolint"
clone_full "https://github.com/jesseduffield/lazydocker.git" "containers/docker/lazydocker" "LazyDocker"
clone_full "https://github.com/docker/awesome-compose.git" "containers/docker/awesome-compose" "Awesome Compose"
clone_full "https://github.com/GoogleContainerTools/distroless.git" "containers/docker/distroless" "Distroless"

section "Podman & OCI"
mkdir -p containers/podman
clone_sparse "https://github.com/containers/podman.git" "containers/podman/core" "Podman" "docs"
clone_sparse "https://github.com/containers/buildah.git" "containers/podman/buildah" "Buildah" "docs"
clone_sparse "https://github.com/containers/skopeo.git" "containers/podman/skopeo" "Skopeo" "docs"
clone_full "https://github.com/containers/podman-compose.git" "containers/podman/compose" "Podman Compose"
clone_full "https://github.com/opencontainers/image-spec.git" "containers/oci/image-spec" "OCI Image Spec"
clone_full "https://github.com/opencontainers/runtime-spec.git" "containers/oci/runtime-spec" "OCI Runtime Spec"

section "Registries"
mkdir -p containers/registries
clone_sparse "https://github.com/distribution/distribution.git" "containers/registries/distribution" "Docker Registry" "docs"
clone_sparse "https://github.com/goharbor/harbor.git" "containers/registries/harbor" "Harbor" "docs"

echo -e "${GREEN}✅ Section Containers terminée${NC}"

#===============================================================================
#  SECTION 4: KUBERNETES
#===============================================================================
banner "📚 SECTION 4: KUBERNETES"

section "Documentation Kubernetes"
mkdir -p kubernetes/docs
clone_sparse "https://github.com/kubernetes/website.git" "kubernetes/docs/website" "K8s Website" "content/en/docs"
clone_full "https://github.com/kubernetes/examples.git" "kubernetes/docs/examples" "K8s Examples"
clone_full "https://github.com/kubernetes/community.git" "kubernetes/docs/community" "K8s Community"

section "Installation Kubernetes"
mkdir -p kubernetes/install
clone_full "https://github.com/kubernetes-sigs/kubespray.git" "kubernetes/install/kubespray" "Kubespray"
clone_full "https://github.com/k3s-io/k3s.git" "kubernetes/install/k3s" "K3s"
clone_full "https://github.com/rancher/rke2.git" "kubernetes/install/rke2" "RKE2"
clone_full "https://github.com/rancher/rancher.git" "kubernetes/install/rancher" "Rancher"
clone_full "https://github.com/kubernetes-sigs/kind.git" "kubernetes/install/kind" "Kind"
clone_full "https://github.com/kubernetes/minikube.git" "kubernetes/install/minikube" "Minikube"

section "Helm"
mkdir -p kubernetes/helm
clone_full "https://github.com/helm/helm.git" "kubernetes/helm/core" "Helm"
clone_sparse "https://github.com/helm/helm-www.git" "kubernetes/helm/website" "Helm Website" "content"
clone_full "https://github.com/helm/chartmuseum.git" "kubernetes/helm/chartmuseum" "ChartMuseum"
clone_full "https://github.com/roboll/helmfile.git" "kubernetes/helm/helmfile" "Helmfile"
clone_full "https://github.com/jkroepke/helm-secrets.git" "kubernetes/helm/helm-secrets" "Helm Secrets"
clone_full "https://github.com/norwoodj/helm-docs.git" "kubernetes/helm/helm-docs" "Helm Docs"

section "GitOps"
mkdir -p kubernetes/gitops
clone_sparse "https://github.com/argoproj/argo-cd.git" "kubernetes/gitops/argocd" "ArgoCD" "docs"
clone_full "https://github.com/argoproj/argo-workflows.git" "kubernetes/gitops/argo-workflows" "Argo Workflows"
clone_full "https://github.com/argoproj/argo-rollouts.git" "kubernetes/gitops/argo-rollouts" "Argo Rollouts"
clone_sparse "https://github.com/fluxcd/flux2.git" "kubernetes/gitops/flux" "Flux" "docs"
clone_full "https://github.com/fluxcd/flagger.git" "kubernetes/gitops/flagger" "Flagger"

section "Outils Kubernetes"
mkdir -p kubernetes/tools
clone_sparse "https://github.com/kubernetes-sigs/kustomize.git" "kubernetes/tools/kustomize" "Kustomize" "docs"
clone_full "https://github.com/kubernetes/kompose.git" "kubernetes/tools/kompose" "Kompose"
clone_full "https://github.com/derailed/k9s.git" "kubernetes/tools/k9s" "K9s"
clone_full "https://github.com/ahmetb/kubectx.git" "kubernetes/tools/kubectx" "Kubectx"
clone_full "https://github.com/kubernetes-sigs/krew.git" "kubernetes/tools/krew" "Krew"
clone_full "https://github.com/stern/stern.git" "kubernetes/tools/stern" "Stern"
clone_full "https://github.com/johanhaleby/kubetail.git" "kubernetes/tools/kubetail" "Kubetail"
clone_full "https://github.com/txn2/kubefwd.git" "kubernetes/tools/kubefwd" "Kubefwd"
clone_full "https://github.com/yannh/kubeconform.git" "kubernetes/tools/kubeconform" "Kubeconform"
clone_full "https://github.com/stackrox/kube-linter.git" "kubernetes/tools/kube-linter" "Kube-Linter"

section "Ingress & Service Mesh"
mkdir -p kubernetes/networking
clone_sparse "https://github.com/kubernetes/ingress-nginx.git" "kubernetes/networking/ingress-nginx" "Ingress NGINX" "docs"
clone_sparse "https://github.com/traefik/traefik.git" "kubernetes/networking/traefik" "Traefik" "docs"
clone_full "https://github.com/haproxytech/kubernetes-ingress.git" "kubernetes/networking/haproxy" "HAProxy Ingress"
clone_full "https://github.com/linkerd/linkerd2.git" "kubernetes/networking/linkerd" "Linkerd"
clone_full "https://github.com/cilium/cilium.git" "kubernetes/networking/cilium" "Cilium"
clone_full "https://github.com/metallb/metallb.git" "kubernetes/networking/metallb" "MetalLB"
clone_full "https://github.com/projectcalico/calico.git" "kubernetes/networking/calico" "Calico"

section "Storage Kubernetes"
mkdir -p kubernetes/storage
clone_sparse "https://github.com/rook/rook.git" "kubernetes/storage/rook" "Rook Ceph" "docs"
clone_sparse "https://github.com/longhorn/longhorn.git" "kubernetes/storage/longhorn" "Longhorn" "docs"
clone_full "https://github.com/openebs/openebs.git" "kubernetes/storage/openebs" "OpenEBS"
clone_full "https://github.com/minio/minio.git" "kubernetes/storage/minio" "MinIO"

section "Sécurité Kubernetes"
mkdir -p kubernetes/security
clone_sparse "https://github.com/cert-manager/cert-manager.git" "kubernetes/security/cert-manager" "Cert-Manager" "docs"
clone_sparse "https://github.com/falcosecurity/falco.git" "kubernetes/security/falco" "Falco" "docs"
clone_sparse "https://github.com/aquasecurity/trivy.git" "kubernetes/security/trivy" "Trivy" "docs"
clone_full "https://github.com/aquasecurity/trivy-operator.git" "kubernetes/security/trivy-operator" "Trivy Operator"
clone_full "https://github.com/open-policy-agent/gatekeeper.git" "kubernetes/security/gatekeeper" "OPA Gatekeeper"
clone_full "https://github.com/kyverno/kyverno.git" "kubernetes/security/kyverno" "Kyverno"
clone_full "https://github.com/external-secrets/external-secrets.git" "kubernetes/security/external-secrets" "External Secrets"
clone_full "https://github.com/bitnami-labs/sealed-secrets.git" "kubernetes/security/sealed-secrets" "Sealed Secrets"
clone_full "https://github.com/aquasecurity/kube-bench.git" "kubernetes/security/kube-bench" "Kube-Bench"
clone_full "https://github.com/FairwindsOps/polaris.git" "kubernetes/security/polaris" "Polaris"

section "Backup Kubernetes"
mkdir -p kubernetes/backup
clone_sparse "https://github.com/vmware-tanzu/velero.git" "kubernetes/backup/velero" "Velero" "site/content"

section "Autoscaling"
mkdir -p kubernetes/autoscaling
clone_full "https://github.com/kubernetes/autoscaler.git" "kubernetes/autoscaling/cluster-autoscaler" "Cluster Autoscaler"
clone_full "https://github.com/kedacore/keda.git" "kubernetes/autoscaling/keda" "KEDA"

echo -e "${GREEN}✅ Section Kubernetes terminée${NC}"


#===============================================================================
#  SECTION 5: CI/CD
#===============================================================================
banner "📚 SECTION 5: CI/CD"

section "GitLab"
mkdir -p cicd/gitlab
clone_sparse "https://github.com/gitlabhq/gitlab.git" "cicd/gitlab/docs" "GitLab Docs" "doc"
clone_full "https://github.com/gitlabhq/gitlab-runner.git" "cicd/gitlab/runner" "GitLab Runner"

section "Jenkins"
mkdir -p cicd/jenkins
clone_full "https://github.com/jenkinsci/jenkins.git" "cicd/jenkins/core" "Jenkins Core"
clone_full "https://github.com/jenkinsci/pipeline-examples.git" "cicd/jenkins/pipeline-examples" "Pipeline Examples"
clone_full "https://github.com/jenkinsci/job-dsl-plugin.git" "cicd/jenkins/job-dsl" "Job DSL"
clone_full "https://github.com/jenkinsci/configuration-as-code-plugin.git" "cicd/jenkins/jcasc" "JCasC"
clone_full "https://github.com/jenkinsci/kubernetes-plugin.git" "cicd/jenkins/kubernetes" "K8s Plugin"
clone_full "https://github.com/jenkinsci/docker-workflow-plugin.git" "cicd/jenkins/docker-workflow" "Docker Workflow"

section "GitHub Actions"
mkdir -p cicd/github-actions
clone_full "https://github.com/actions/runner.git" "cicd/github-actions/runner" "GHA Runner"
clone_full "https://github.com/actions/checkout.git" "cicd/github-actions/checkout" "checkout"
clone_full "https://github.com/actions/setup-python.git" "cicd/github-actions/setup-python" "setup-python"
clone_full "https://github.com/actions/setup-node.git" "cicd/github-actions/setup-node" "setup-node"
clone_full "https://github.com/actions/cache.git" "cicd/github-actions/cache" "cache"
clone_full "https://github.com/actions/upload-artifact.git" "cicd/github-actions/upload-artifact" "upload-artifact"
clone_full "https://github.com/docker/build-push-action.git" "cicd/github-actions/docker-build-push" "docker-build-push"
clone_full "https://github.com/docker/login-action.git" "cicd/github-actions/docker-login" "docker-login"
clone_full "https://github.com/docker/setup-buildx-action.git" "cicd/github-actions/docker-buildx" "docker-buildx"
clone_full "https://github.com/hashicorp/setup-terraform.git" "cicd/github-actions/setup-terraform" "setup-terraform"
clone_full "https://github.com/github/super-linter.git" "cicd/github-actions/super-linter" "Super Linter"
clone_full "https://github.com/nektos/act.git" "cicd/github-actions/act" "Act (local runner)"
clone_full "https://github.com/sdras/awesome-actions.git" "cicd/github-actions/awesome" "Awesome Actions"

section "Autres CI/CD"
mkdir -p cicd/other
clone_full "https://github.com/tektoncd/pipeline.git" "cicd/other/tekton" "Tekton"
clone_full "https://github.com/harness/drone.git" "cicd/other/drone" "Drone"
clone_full "https://github.com/woodpecker-ci/woodpecker.git" "cicd/other/woodpecker" "Woodpecker"

section "Code Quality"
mkdir -p cicd/quality
clone_full "https://github.com/SonarSource/sonarqube.git" "cicd/quality/sonarqube" "SonarQube"
clone_full "https://github.com/reviewdog/reviewdog.git" "cicd/quality/reviewdog" "Reviewdog"

section "Artifact Management"
mkdir -p cicd/artifacts
clone_full "https://github.com/sonatype/nexus-public.git" "cicd/artifacts/nexus" "Nexus"

section "Git"
mkdir -p cicd/git
clone_full "https://github.com/progit/progit2.git" "cicd/git/progit" "Pro Git Book"
clone_full "https://github.com/git-tips/tips.git" "cicd/git/tips" "Git Tips"
clone_full "https://github.com/k88hudson/git-flight-rules.git" "cicd/git/flight-rules" "Git Flight Rules"
clone_full "https://github.com/conventional-commits/conventionalcommits.org.git" "cicd/git/conventional-commits" "Conventional Commits"
clone_full "https://github.com/semantic-release/semantic-release.git" "cicd/git/semantic-release" "Semantic Release"
clone_full "https://github.com/go-gitea/gitea.git" "cicd/git/gitea" "Gitea"
clone_full "https://github.com/jesseduffield/lazygit.git" "cicd/git/lazygit" "LazyGit"
clone_full "https://github.com/tj/git-extras.git" "cicd/git/git-extras" "Git Extras"
clone_full "https://github.com/pre-commit/pre-commit.git" "cicd/git/pre-commit" "pre-commit"
clone_full "https://github.com/pre-commit/pre-commit-hooks.git" "cicd/git/pre-commit-hooks" "pre-commit-hooks"

echo -e "${GREEN}✅ Section CI/CD terminée${NC}"

#===============================================================================
#  SECTION 6: PYTHON
#===============================================================================
banner "📚 SECTION 6: PYTHON"

section "Python Core"
mkdir -p languages/python/core
clone_sparse "https://github.com/python/cpython.git" "languages/python/core/cpython" "Python CPython" "Doc Lib"
clone_full "https://github.com/python/peps.git" "languages/python/core/peps" "Python PEPs"

section "Python - HTTP & Web"
mkdir -p languages/python/web
clone_full "https://github.com/psf/requests.git" "languages/python/web/requests" "requests"
clone_full "https://github.com/encode/httpx.git" "languages/python/web/httpx" "httpx"
clone_full "https://github.com/aio-libs/aiohttp.git" "languages/python/web/aiohttp" "aiohttp"
clone_full "https://github.com/urllib3/urllib3.git" "languages/python/web/urllib3" "urllib3"

section "Python - Frameworks Web"
mkdir -p languages/python/frameworks
clone_full "https://github.com/tiangolo/fastapi.git" "languages/python/frameworks/fastapi" "FastAPI"
clone_full "https://github.com/pallets/flask.git" "languages/python/frameworks/flask" "Flask"
clone_sparse "https://github.com/django/django.git" "languages/python/frameworks/django" "Django" "docs"
clone_full "https://github.com/encode/starlette.git" "languages/python/frameworks/starlette" "Starlette"
clone_full "https://github.com/encode/uvicorn.git" "languages/python/frameworks/uvicorn" "Uvicorn"

section "Python - CLI"
mkdir -p languages/python/cli
clone_full "https://github.com/pallets/click.git" "languages/python/cli/click" "Click"
clone_full "https://github.com/tiangolo/typer.git" "languages/python/cli/typer" "Typer"
clone_full "https://github.com/Textualize/rich.git" "languages/python/cli/rich" "Rich"
clone_full "https://github.com/google/python-fire.git" "languages/python/cli/fire" "Python Fire"
clone_full "https://github.com/tqdm/tqdm.git" "languages/python/cli/tqdm" "tqdm"

section "Python - Data & Validation"
mkdir -p languages/python/data
clone_full "https://github.com/pydantic/pydantic.git" "languages/python/data/pydantic" "Pydantic"
clone_full "https://github.com/marshmallow-code/marshmallow.git" "languages/python/data/marshmallow" "Marshmallow"
clone_full "https://github.com/python-attrs/attrs.git" "languages/python/data/attrs" "Attrs"
clone_full "https://github.com/pandas-dev/pandas.git" "languages/python/data/pandas" "Pandas"

section "Python - Fichiers & Formats"
mkdir -p languages/python/formats
clone_full "https://github.com/yaml/pyyaml.git" "languages/python/formats/pyyaml" "PyYAML"
clone_full "https://github.com/pallets/jinja.git" "languages/python/formats/jinja2" "Jinja2"
clone_full "https://github.com/ijl/orjson.git" "languages/python/formats/orjson" "orjson"
clone_full "https://github.com/python-jsonschema/jsonschema.git" "languages/python/formats/jsonschema" "jsonschema"

section "Python - SSH & Remote"
mkdir -p languages/python/remote
clone_full "https://github.com/paramiko/paramiko.git" "languages/python/remote/paramiko" "Paramiko"
clone_full "https://github.com/fabric/fabric.git" "languages/python/remote/fabric" "Fabric"
clone_full "https://github.com/pyinvoke/invoke.git" "languages/python/remote/invoke" "Invoke"
clone_full "https://github.com/sshuttle/sshuttle.git" "languages/python/remote/sshuttle" "sshuttle"

section "Python - Réseau & Automatisation"
mkdir -p languages/python/network
clone_full "https://github.com/ktbyers/netmiko.git" "languages/python/network/netmiko" "Netmiko"
clone_full "https://github.com/napalm-automation/napalm.git" "languages/python/network/napalm" "NAPALM"
clone_full "https://github.com/nornir-automation/nornir.git" "languages/python/network/nornir" "Nornir"
clone_full "https://github.com/carlmontanari/scrapli.git" "languages/python/network/scrapli" "Scrapli"

section "Python - Databases"
mkdir -p languages/python/databases
clone_full "https://github.com/sqlalchemy/sqlalchemy.git" "languages/python/databases/sqlalchemy" "SQLAlchemy"
clone_full "https://github.com/psycopg/psycopg2.git" "languages/python/databases/psycopg2" "Psycopg2"
clone_full "https://github.com/PyMySQL/PyMySQL.git" "languages/python/databases/pymysql" "PyMySQL"
clone_full "https://github.com/redis/redis-py.git" "languages/python/databases/redis" "redis-py"
clone_full "https://github.com/mongodb/mongo-python-driver.git" "languages/python/databases/pymongo" "PyMongo"
clone_full "https://github.com/elastic/elasticsearch-py.git" "languages/python/databases/elasticsearch" "elasticsearch-py"
clone_full "https://github.com/python-ldap/python-ldap.git" "languages/python/databases/ldap" "python-ldap"

section "Python - Testing"
mkdir -p languages/python/testing
clone_full "https://github.com/pytest-dev/pytest.git" "languages/python/testing/pytest" "Pytest"
clone_full "https://github.com/pytest-dev/pytest-cov.git" "languages/python/testing/pytest-cov" "pytest-cov"
clone_full "https://github.com/pytest-dev/pytest-mock.git" "languages/python/testing/pytest-mock" "pytest-mock"
clone_full "https://github.com/spulec/moto.git" "languages/python/testing/moto" "Moto"
clone_full "https://github.com/getsentry/responses.git" "languages/python/testing/responses" "Responses"

section "Python - Sécurité & Crypto"
mkdir -p languages/python/security
clone_full "https://github.com/pyca/cryptography.git" "languages/python/security/cryptography" "cryptography"
clone_full "https://github.com/pyca/bcrypt.git" "languages/python/security/bcrypt" "bcrypt"
clone_full "https://github.com/jpadilla/pyjwt.git" "languages/python/security/pyjwt" "PyJWT"

section "Python - Cloud & Storage"
mkdir -p languages/python/cloud
clone_full "https://github.com/boto/boto3.git" "languages/python/cloud/boto3" "Boto3"
clone_full "https://github.com/minio/minio-py.git" "languages/python/cloud/minio" "MinIO Python"

section "Python - Logging & Monitoring"
mkdir -p languages/python/logging
clone_full "https://github.com/hynek/structlog.git" "languages/python/logging/structlog" "structlog"
clone_full "https://github.com/Delgan/loguru.git" "languages/python/logging/loguru" "Loguru"
clone_full "https://github.com/prometheus/client_python.git" "languages/python/logging/prometheus" "Prometheus Client"
clone_full "https://github.com/open-telemetry/opentelemetry-python.git" "languages/python/logging/opentelemetry" "OpenTelemetry"

section "Python - Outils"
mkdir -p languages/python/tools
clone_full "https://github.com/python-poetry/poetry.git" "languages/python/tools/poetry" "Poetry"
clone_full "https://github.com/pypa/pip.git" "languages/python/tools/pip" "Pip"
clone_full "https://github.com/pyenv/pyenv.git" "languages/python/tools/pyenv" "Pyenv"
clone_full "https://github.com/astral-sh/ruff.git" "languages/python/tools/ruff" "Ruff"
clone_full "https://github.com/psf/black.git" "languages/python/tools/black" "Black"
clone_full "https://github.com/PyCQA/flake8.git" "languages/python/tools/flake8" "Flake8"
clone_full "https://github.com/PyCQA/pylint.git" "languages/python/tools/pylint" "Pylint"
clone_full "https://github.com/python/mypy.git" "languages/python/tools/mypy" "Mypy"

section "Python - Guides"
mkdir -p languages/python/guides
clone_full "https://github.com/faif/python-patterns.git" "languages/python/guides/patterns" "Python Patterns"
clone_full "https://github.com/satwikkansal/wtfpython.git" "languages/python/guides/wtfpython" "WTF Python"
clone_full "https://github.com/TheAlgorithms/Python.git" "languages/python/guides/algorithms" "Python Algorithms"
clone_full "https://github.com/vinta/awesome-python.git" "languages/python/guides/awesome" "Awesome Python"

echo -e "${GREEN}✅ Section Python terminée${NC}"

#===============================================================================
#  SECTION 7: BASH/SHELL
#===============================================================================
banner "📚 SECTION 7: BASH/SHELL"

mkdir -p languages/bash
clone_full "https://github.com/dylanaraps/pure-bash-bible.git" "languages/bash/pure-bash-bible" "Pure Bash Bible"
clone_full "https://github.com/jlevy/the-art-of-command-line.git" "languages/bash/art-of-cli" "Art of Command Line"
clone_full "https://github.com/koalaman/shellcheck.git" "languages/bash/shellcheck" "ShellCheck"
clone_full "https://github.com/awesome-lists/awesome-bash.git" "languages/bash/awesome" "Awesome Bash"
clone_full "https://github.com/bats-core/bats-core.git" "languages/bash/bats" "Bats Testing"
clone_full "https://github.com/mvdan/sh.git" "languages/bash/shfmt" "shfmt"
clone_full "https://github.com/onceupon/Bash-Oneliner.git" "languages/bash/oneliners" "Bash Oneliners"
clone_full "https://github.com/alexanderepstein/Bash-Snippets.git" "languages/bash/snippets" "Bash Snippets"
clone_full "https://github.com/denysdovhan/bash-handbook.git" "languages/bash/handbook" "Bash Handbook"
clone_full "https://github.com/ohmyzsh/ohmyzsh.git" "languages/bash/ohmyzsh" "Oh My Zsh"
clone_full "https://github.com/starship/starship.git" "languages/bash/starship" "Starship Prompt"
clone_full "https://github.com/Bash-it/bash-it.git" "languages/bash/bash-it" "Bash-it"

echo -e "${GREEN}✅ Section Bash terminée${NC}"

#===============================================================================
#  SECTION 8: POWERSHELL
#===============================================================================
banner "📚 SECTION 8: POWERSHELL"

mkdir -p languages/powershell
clone_sparse "https://github.com/MicrosoftDocs/PowerShell-Docs.git" "languages/powershell/docs" "PowerShell Docs" "reference"
clone_full "https://github.com/PowerShell/PowerShell.git" "languages/powershell/core" "PowerShell Core"
clone_full "https://github.com/PoshCode/PowerShellPracticeAndStyle.git" "languages/powershell/style-guide" "PowerShell Style Guide"
clone_full "https://github.com/janikvonrotz/awesome-powershell.git" "languages/powershell/awesome" "Awesome PowerShell"
clone_full "https://github.com/pester/Pester.git" "languages/powershell/pester" "Pester"
clone_full "https://github.com/PowerShell/PSScriptAnalyzer.git" "languages/powershell/script-analyzer" "PSScriptAnalyzer"
clone_full "https://github.com/PowerShell/DscResources.git" "languages/powershell/dsc" "DSC Resources"
clone_full "https://github.com/dsccommunity/CommonTasks.git" "languages/powershell/dsc-common" "DSC Common Tasks"

echo -e "${GREEN}✅ Section PowerShell terminée${NC}"

#===============================================================================
#  SECTION 9: GO & RUST
#===============================================================================
banner "📚 SECTION 9: GO & RUST"

section "Go"
mkdir -p languages/go
clone_sparse "https://github.com/golang/go.git" "languages/go/docs" "Go Docs" "doc src"
clone_full "https://github.com/golang-standards/project-layout.git" "languages/go/project-layout" "Go Project Layout"
clone_full "https://github.com/avelino/awesome-go.git" "languages/go/awesome" "Awesome Go"
clone_full "https://github.com/quii/learn-go-with-tests.git" "languages/go/learn-tests" "Learn Go With Tests"
clone_full "https://github.com/tmrts/go-patterns.git" "languages/go/patterns" "Go Patterns"
clone_full "https://github.com/uber-go/guide.git" "languages/go/uber-guide" "Uber Go Guide"

section "Rust"
mkdir -p languages/rust
clone_full "https://github.com/rust-lang/book.git" "languages/rust/book" "The Rust Book"
clone_full "https://github.com/rust-lang/rust-by-example.git" "languages/rust/by-example" "Rust By Example"
clone_full "https://github.com/rust-unofficial/awesome-rust.git" "languages/rust/awesome" "Awesome Rust"

section "Formats de données"
mkdir -p languages/formats
clone_full "https://github.com/yaml/yaml-spec.git" "languages/formats/yaml" "YAML Spec"
clone_full "https://github.com/toml-lang/toml.git" "languages/formats/toml" "TOML Spec"
clone_full "https://github.com/json-schema-org/json-schema-spec.git" "languages/formats/json-schema" "JSON Schema"
clone_full "https://github.com/hashicorp/hcl.git" "languages/formats/hcl" "HCL"

section "Regex & SQL"
mkdir -p languages/regex
clone_full "https://github.com/ziishaned/learn-regex.git" "languages/regex/learn" "Learn Regex"

echo -e "${GREEN}✅ Section Go/Rust terminée${NC}"


#===============================================================================
#  SECTION 10: SÉCURITÉ
#===============================================================================
banner "📚 SECTION 10: SÉCURITÉ"

section "Guides de Sécurité"
mkdir -p security/guides
clone_full "https://github.com/decalage2/awesome-security-hardening.git" "security/guides/awesome-hardening" "Awesome Hardening"
clone_sparse "https://github.com/OWASP/CheatSheetSeries.git" "security/guides/owasp-cheatsheets" "OWASP Cheatsheets" "cheatsheets"
clone_full "https://github.com/OWASP/wstg.git" "security/guides/owasp-wstg" "OWASP WSTG"
clone_full "https://github.com/OWASP/ASVS.git" "security/guides/owasp-asvs" "OWASP ASVS"
clone_full "https://github.com/trimstray/the-practical-linux-hardening-guide.git" "security/guides/linux-hardening" "Linux Hardening"
clone_full "https://github.com/imthenachoman/How-To-Secure-A-Linux-Server.git" "security/guides/secure-linux" "Secure Linux Server"

section "ANSSI"
mkdir -p security/anssi
clone_full "https://github.com/ANSSI-FR/guide-journalisation-microsoft.git" "security/anssi/windows-logging" "Windows Logging"
clone_full "https://github.com/ANSSI-FR/AD-control-paths.git" "security/anssi/ad-control-paths" "AD Control Paths"

section "Outils de Scan"
mkdir -p security/scanners
clone_sparse "https://github.com/aquasecurity/trivy.git" "security/scanners/trivy" "Trivy" "docs"
clone_full "https://github.com/anchore/grype.git" "security/scanners/grype" "Grype"
clone_full "https://github.com/anchore/syft.git" "security/scanners/syft" "Syft"
clone_full "https://github.com/zaproxy/zaproxy.git" "security/scanners/zap" "OWASP ZAP"
clone_full "https://github.com/sullo/nikto.git" "security/scanners/nikto" "Nikto"
clone_full "https://github.com/CISOfy/lynis.git" "security/scanners/lynis" "Lynis"

section "Secrets & Credentials"
mkdir -p security/secrets
clone_full "https://github.com/gitleaks/gitleaks.git" "security/secrets/gitleaks" "Gitleaks"
clone_full "https://github.com/trufflesecurity/trufflehog.git" "security/secrets/trufflehog" "TruffleHog"
clone_full "https://github.com/awslabs/git-secrets.git" "security/secrets/git-secrets" "git-secrets"
clone_full "https://github.com/mozilla/sops.git" "security/secrets/sops" "SOPS"
clone_full "https://github.com/FiloSottile/age.git" "security/secrets/age" "Age Encryption"

section "Firewall & Réseau"
mkdir -p security/network
clone_full "https://github.com/fail2ban/fail2ban.git" "security/network/fail2ban" "Fail2ban"
clone_full "https://github.com/crowdsecurity/crowdsec.git" "security/network/crowdsec" "CrowdSec"
clone_full "https://github.com/firehol/firehol.git" "security/network/firehol" "FireHOL"

section "SSL/TLS & PKI"
mkdir -p security/ssl
clone_sparse "https://github.com/openssl/openssl.git" "security/ssl/openssl" "OpenSSL" "doc"
clone_full "https://github.com/certbot/certbot.git" "security/ssl/certbot" "Certbot"
clone_full "https://github.com/acmesh-official/acme.sh.git" "security/ssl/acme-sh" "acme.sh"
clone_full "https://github.com/smallstep/certificates.git" "security/ssl/step-ca" "Step CA"
clone_full "https://github.com/FiloSottile/mkcert.git" "security/ssl/mkcert" "mkcert"
clone_full "https://github.com/drwetter/testssl.sh.git" "security/ssl/testssl" "testssl.sh"
clone_full "https://github.com/trimstray/nginx-admins-handbook.git" "security/ssl/nginx-handbook" "NGINX Handbook"

section "Audit Linux"
mkdir -p security/audit
clone_full "https://github.com/linux-audit/audit-userspace.git" "security/audit/audit-userspace" "Linux Audit"
clone_full "https://github.com/ossec/ossec-hids.git" "security/audit/ossec" "OSSEC"
clone_full "https://github.com/wazuh/wazuh.git" "security/audit/wazuh" "Wazuh"

section "Audit Windows"
mkdir -p security/windows
clone_full "https://github.com/BloodHoundAD/BloodHound.git" "security/windows/bloodhound" "BloodHound"
clone_full "https://github.com/GhostPack/Seatbelt.git" "security/windows/seatbelt" "Seatbelt"
clone_full "https://github.com/SecureAuthCorp/impacket.git" "security/windows/impacket" "Impacket"

section "Identity & Access"
mkdir -p security/iam
clone_full "https://github.com/keycloak/keycloak.git" "security/iam/keycloak" "Keycloak"
clone_full "https://github.com/dexidp/dex.git" "security/iam/dex" "Dex"
clone_full "https://github.com/oauth2-proxy/oauth2-proxy.git" "security/iam/oauth2-proxy" "OAuth2 Proxy"
clone_full "https://github.com/authelia/authelia.git" "security/iam/authelia" "Authelia"

section "Compliance"
mkdir -p security/compliance
clone_full "https://github.com/ComplianceAsCode/content.git" "security/compliance/scap" "SCAP Content"
clone_full "https://github.com/bridgecrewio/checkov.git" "security/compliance/checkov" "Checkov"
clone_full "https://github.com/Checkmarx/kics.git" "security/compliance/kics" "KICS"

echo -e "${GREEN}✅ Section Sécurité terminée${NC}"

#===============================================================================
#  SECTION 11: MONITORING
#===============================================================================
banner "📚 SECTION 11: MONITORING"

section "Prometheus"
mkdir -p monitoring/prometheus
clone_full "https://github.com/prometheus/prometheus.git" "monitoring/prometheus/core" "Prometheus"
clone_full "https://github.com/prometheus/alertmanager.git" "monitoring/prometheus/alertmanager" "Alertmanager"
clone_full "https://github.com/prometheus/node_exporter.git" "monitoring/prometheus/node-exporter" "Node Exporter"
clone_full "https://github.com/prometheus/blackbox_exporter.git" "monitoring/prometheus/blackbox-exporter" "Blackbox Exporter"
clone_full "https://github.com/prometheus/snmp_exporter.git" "monitoring/prometheus/snmp-exporter" "SNMP Exporter"
clone_full "https://github.com/prometheus-community/postgres_exporter.git" "monitoring/prometheus/postgres-exporter" "PostgreSQL Exporter"
clone_full "https://github.com/prometheus-community/windows_exporter.git" "monitoring/prometheus/windows-exporter" "Windows Exporter"
clone_full "https://github.com/google/cadvisor.git" "monitoring/prometheus/cadvisor" "cAdvisor"
clone_full "https://github.com/prometheus/pushgateway.git" "monitoring/prometheus/pushgateway" "Pushgateway"
clone_full "https://github.com/prometheus/docs.git" "monitoring/prometheus/docs" "Prometheus Docs"
clone_full "https://github.com/samber/awesome-prometheus-alerts.git" "monitoring/prometheus/awesome-alerts" "Awesome Alerts"
clone_full "https://github.com/prometheus-operator/prometheus-operator.git" "monitoring/prometheus/operator" "Prometheus Operator"
clone_full "https://github.com/prometheus-operator/kube-prometheus.git" "monitoring/prometheus/kube-prometheus" "Kube Prometheus"
clone_full "https://github.com/thanos-io/thanos.git" "monitoring/prometheus/thanos" "Thanos"
clone_full "https://github.com/VictoriaMetrics/VictoriaMetrics.git" "monitoring/prometheus/victoriametrics" "VictoriaMetrics"

section "Grafana"
mkdir -p monitoring/grafana
clone_sparse "https://github.com/grafana/grafana.git" "monitoring/grafana/core" "Grafana" "docs"
clone_sparse "https://github.com/grafana/loki.git" "monitoring/grafana/loki" "Loki" "docs"
clone_sparse "https://github.com/grafana/tempo.git" "monitoring/grafana/tempo" "Tempo" "docs"
clone_sparse "https://github.com/grafana/mimir.git" "monitoring/grafana/mimir" "Mimir" "docs"
clone_full "https://github.com/grafana/alloy.git" "monitoring/grafana/alloy" "Alloy"
clone_full "https://github.com/grafana/oncall.git" "monitoring/grafana/oncall" "Grafana OnCall"
clone_full "https://github.com/grafana/jsonnet-libs.git" "monitoring/grafana/jsonnet-libs" "Grafana Jsonnet"
clone_full "https://github.com/grafana/grafonnet-lib.git" "monitoring/grafana/grafonnet" "Grafonnet"

section "OpenTelemetry"
mkdir -p monitoring/opentelemetry
clone_sparse "https://github.com/open-telemetry/opentelemetry.io.git" "monitoring/opentelemetry/docs" "OTel Docs" "content"
clone_full "https://github.com/open-telemetry/opentelemetry-collector.git" "monitoring/opentelemetry/collector" "OTel Collector"
clone_full "https://github.com/open-telemetry/opentelemetry-collector-contrib.git" "monitoring/opentelemetry/collector-contrib" "OTel Collector Contrib"

section "Tracing"
mkdir -p monitoring/tracing
clone_full "https://github.com/jaegertracing/jaeger.git" "monitoring/tracing/jaeger" "Jaeger"
clone_full "https://github.com/openzipkin/zipkin.git" "monitoring/tracing/zipkin" "Zipkin"
clone_full "https://github.com/SigNoz/signoz.git" "monitoring/tracing/signoz" "SigNoz"

section "ELK Stack"
mkdir -p monitoring/elastic
clone_sparse "https://github.com/elastic/elasticsearch.git" "monitoring/elastic/elasticsearch" "Elasticsearch" "docs"
clone_sparse "https://github.com/elastic/logstash.git" "monitoring/elastic/logstash" "Logstash" "docs"
clone_sparse "https://github.com/elastic/kibana.git" "monitoring/elastic/kibana" "Kibana" "docs"
clone_sparse "https://github.com/elastic/beats.git" "monitoring/elastic/beats" "Beats" "docs"
clone_full "https://github.com/deviantony/docker-elk.git" "monitoring/elastic/docker-elk" "Docker ELK"

section "Zabbix"
mkdir -p monitoring/zabbix
clone_full "https://github.com/zabbix/zabbix.git" "monitoring/zabbix/core" "Zabbix"
clone_full "https://github.com/zabbix/zabbix-docker.git" "monitoring/zabbix/docker" "Zabbix Docker"

section "Log Management"
mkdir -p monitoring/logs
clone_full "https://github.com/fluent/fluentd.git" "monitoring/logs/fluentd" "Fluentd"
clone_full "https://github.com/fluent/fluent-bit.git" "monitoring/logs/fluent-bit" "Fluent Bit"
clone_full "https://github.com/graylog2/graylog2-server.git" "monitoring/logs/graylog" "Graylog"
clone_full "https://github.com/timberio/vector.git" "monitoring/logs/vector" "Vector"

section "Status Pages"
mkdir -p monitoring/status
clone_full "https://github.com/louislam/uptime-kuma.git" "monitoring/status/uptime-kuma" "Uptime Kuma"
clone_full "https://github.com/healthchecks/healthchecks.git" "monitoring/status/healthchecks" "Healthchecks"

echo -e "${GREEN}✅ Section Monitoring terminée${NC}"

#===============================================================================
#  SECTION 12: INFRASTRUCTURE
#===============================================================================
banner "📚 SECTION 12: INFRASTRUCTURE"

section "HashiCorp Stack"
mkdir -p infrastructure/hashicorp
clone_sparse "https://github.com/hashicorp/vault.git" "infrastructure/hashicorp/vault" "Vault" "website/content"
clone_sparse "https://github.com/hashicorp/consul.git" "infrastructure/hashicorp/consul" "Consul" "website/content"
clone_sparse "https://github.com/hashicorp/nomad.git" "infrastructure/hashicorp/nomad" "Nomad" "website/content"
clone_sparse "https://github.com/hashicorp/packer.git" "infrastructure/hashicorp/packer" "Packer" "website/content"
clone_sparse "https://github.com/hashicorp/boundary.git" "infrastructure/hashicorp/boundary" "Boundary" "website/content"
clone_sparse "https://github.com/hashicorp/vagrant.git" "infrastructure/hashicorp/vagrant" "Vagrant" "website/content"

section "Web Servers & Proxies"
mkdir -p infrastructure/webservers
clone_sparse "https://github.com/nginx/nginx.git" "infrastructure/webservers/nginx" "NGINX" "docs"
clone_full "https://github.com/nginx/documentation.git" "infrastructure/webservers/nginx-docs" "NGINX Docs"
clone_sparse "https://github.com/traefik/traefik.git" "infrastructure/webservers/traefik" "Traefik" "docs"
clone_sparse "https://github.com/haproxy/haproxy.git" "infrastructure/webservers/haproxy" "HAProxy" "doc"
clone_full "https://github.com/caddyserver/caddy.git" "infrastructure/webservers/caddy" "Caddy"
clone_full "https://github.com/apache/httpd.git" "infrastructure/webservers/apache" "Apache"

section "Bases de données"
mkdir -p infrastructure/databases
clone_sparse "https://github.com/postgres/postgres.git" "infrastructure/databases/postgresql" "PostgreSQL" "doc"
clone_sparse "https://github.com/mysql/mysql-server.git" "infrastructure/databases/mysql" "MySQL" "docs"
clone_full "https://github.com/MariaDB/server.git" "infrastructure/databases/mariadb" "MariaDB"
clone_full "https://github.com/redis/redis.git" "infrastructure/databases/redis" "Redis"
clone_full "https://github.com/redis/redis-doc.git" "infrastructure/databases/redis-docs" "Redis Docs"
clone_sparse "https://github.com/mongodb/mongo.git" "infrastructure/databases/mongodb" "MongoDB" "docs"

section "Message Queues"
mkdir -p infrastructure/messaging
clone_full "https://github.com/apache/kafka-site.git" "infrastructure/messaging/kafka" "Kafka"
clone_full "https://github.com/rabbitmq/rabbitmq-website.git" "infrastructure/messaging/rabbitmq" "RabbitMQ"
clone_full "https://github.com/nats-io/nats-server.git" "infrastructure/messaging/nats" "NATS"

section "DNS"
mkdir -p infrastructure/dns
clone_full "https://github.com/PowerDNS/pdns.git" "infrastructure/dns/powerdns" "PowerDNS"
clone_full "https://github.com/coredns/coredns.git" "infrastructure/dns/coredns" "CoreDNS"
clone_full "https://github.com/NLnetLabs/unbound.git" "infrastructure/dns/unbound" "Unbound"

section "Configuration Management"
mkdir -p infrastructure/config
clone_full "https://github.com/saltstack/salt.git" "infrastructure/config/salt" "Salt"
clone_full "https://github.com/puppetlabs/puppet.git" "infrastructure/config/puppet" "Puppet"

echo -e "${GREEN}✅ Section Infrastructure terminée${NC}"


#===============================================================================
#  SECTION 13: LINUX
#===============================================================================
banner "📚 SECTION 13: LINUX"

section "Kernel & Systemd"
mkdir -p os/linux
clone_sparse "https://github.com/torvalds/linux.git" "os/linux/kernel" "Linux Kernel" "Documentation"
clone_full "https://github.com/systemd/systemd.git" "os/linux/systemd" "Systemd"

section "TLDR & Man Pages"
clone_full "https://github.com/tldr-pages/tldr.git" "os/linux/tldr" "TLDR Pages"
clone_full "https://github.com/chubin/cheat.sh.git" "os/linux/cheat-sh" "Cheat.sh"

section "Package Management"
mkdir -p os/linux/packages
clone_full "https://github.com/rpm-software-management/rpm.git" "os/linux/packages/rpm" "RPM"
clone_full "https://github.com/rpm-software-management/dnf.git" "os/linux/packages/dnf" "DNF"

section "Networking Linux"
mkdir -p os/linux/networking
clone_full "https://github.com/iproute2/iproute2.git" "os/linux/networking/iproute2" "iproute2"

echo -e "${GREEN}✅ Section Linux terminée${NC}"

#===============================================================================
#  SECTION 14: WINDOWS SERVER
#===============================================================================
banner "📚 SECTION 14: WINDOWS SERVER"

mkdir -p os/windows
clone_sparse "https://github.com/MicrosoftDocs/windowsserverdocs.git" "os/windows/server-docs" "Windows Server Docs" "WindowsServerDocs"
#clone_sparse "https://github.com/MicrosoftDocs/windows-itpro-docs.git" "os/windows/itpro" "Windows IT Pro" "windows"  # Repo supprimé, contenu migré sur Microsoft Learn

echo -e "${GREEN}✅ Section Windows terminée${NC}"

#===============================================================================
#  SECTION 15: VMWARE & VIRTUALISATION
#===============================================================================
banner "📚 SECTION 15: VMWARE & VIRTUALISATION"

section "VMware vSphere"
mkdir -p virtualization/vmware
clone_sparse "https://github.com/vmware/vsphere-automation-sdk-python.git" "virtualization/vmware/sdk-python" "vSphere SDK Python" "docs samples"
clone_full "https://github.com/vmware/PowerCLI-Example-Scripts.git" "virtualization/vmware/powercli-examples" "PowerCLI Examples"
#clone_full "https://github.com/vmware-samples/pyvmomi-community-samples.git" "virtualization/vmware/pyvmomi-samples" "PyVmomi Samples"  # Repo supprimé
clone_full "https://github.com/vmware/govmomi.git" "virtualization/vmware/govmomi" "Govmomi"

section "Proxmox"
mkdir -p virtualization/proxmox
clone_full "https://github.com/Telmate/terraform-provider-proxmox.git" "virtualization/proxmox/terraform" "Terraform Proxmox"

section "Libvirt / KVM"
mkdir -p virtualization/libvirt
clone_sparse "https://github.com/libvirt/libvirt.git" "virtualization/libvirt/core" "Libvirt" "docs"
clone_full "https://github.com/virt-manager/virt-manager.git" "virtualization/libvirt/virt-manager" "Virt-Manager"

section "Vagrant"
mkdir -p virtualization/vagrant
clone_full "https://github.com/hashicorp/vagrant.git" "virtualization/vagrant/core" "Vagrant"
#clone_full "https://github.com/bmatcuk/vagrant-microsoft-azure.git" "virtualization/vagrant/examples" "Vagrant Examples"  # Repo supprimé

echo -e "${GREEN}✅ Section Virtualisation terminée${NC}"

#===============================================================================
#  SECTION 16: RÉSEAU
#===============================================================================
banner "📚 SECTION 16: RÉSEAU"

section "Outils Réseau"
mkdir -p network/tools
clone_full "https://github.com/netbox-community/netbox.git" "network/tools/netbox" "NetBox"
clone_full "https://github.com/nautobot/nautobot.git" "network/tools/nautobot" "Nautobot"
clone_full "https://github.com/nmap/nmap.git" "network/tools/nmap" "Nmap"
clone_full "https://github.com/wireshark/wireshark.git" "network/tools/wireshark" "Wireshark"

section "VPN"
mkdir -p network/vpn
clone_full "https://github.com/OpenVPN/openvpn.git" "network/vpn/openvpn" "OpenVPN"
clone_full "https://github.com/WireGuard/wireguard-tools.git" "network/vpn/wireguard" "WireGuard"

echo -e "${GREEN}✅ Section Réseau terminée${NC}"

#===============================================================================
#  SECTION 17: RÉFÉRENCES & CHEATSHEETS
#===============================================================================
banner "📚 SECTION 17: RÉFÉRENCES & CHEATSHEETS"

mkdir -p references
clone_full "https://github.com/tldr-pages/tldr.git" "references/tldr" "TLDR Pages"
clone_full "https://github.com/LeCoupa/awesome-cheatsheets.git" "references/awesome-cheatsheets" "Awesome Cheatsheets"
clone_full "https://github.com/trimstray/the-book-of-secret-knowledge.git" "references/secret-knowledge" "Book of Secret Knowledge"
clone_full "https://github.com/bregman-arie/devops-exercises.git" "references/devops-exercises" "DevOps Exercises"
clone_full "https://github.com/bregman-arie/devops-resources.git" "references/devops-resources" "DevOps Resources"
clone_full "https://github.com/MichaelCade/90DaysOfDevOps.git" "references/90days-devops" "90 Days of DevOps"
clone_full "https://github.com/kamranahmedse/developer-roadmap.git" "references/developer-roadmap" "Developer Roadmap"
clone_full "https://github.com/donnemartin/system-design-primer.git" "references/system-design" "System Design Primer"
clone_full "https://github.com/ripienaar/free-for-dev.git" "references/free-for-dev" "Free for Dev"

echo -e "${GREEN}✅ Section Références terminée${NC}"

#===============================================================================
#  STATISTIQUES FINALES
#===============================================================================
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(((DURATION % 3600) / 60))

banner "📊 STATISTIQUES FINALES"

echo ""
echo "📁 Documentation téléchargée dans: $DOCS_DIR"
echo ""
echo "📊 Statistiques:"
echo "   - Total fichiers:    $(find "$DOCS_DIR" -type f 2>/dev/null | wc -l)"
echo "   - Fichiers Markdown: $(find "$DOCS_DIR" -name "*.md" 2>/dev/null | wc -l)"
echo "   - Fichiers Python:   $(find "$DOCS_DIR" -name "*.py" 2>/dev/null | wc -l)"
echo "   - Fichiers YAML:     $(find "$DOCS_DIR" \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l)"
echo "   - Fichiers Shell:    $(find "$DOCS_DIR" -name "*.sh" 2>/dev/null | wc -l)"
echo ""
echo "💾 Taille totale:"
du -sh "$DOCS_DIR" 2>/dev/null || echo "   Non calculable"
echo ""
echo "⏱️  Durée: ${HOURS}h ${MINUTES}m"
echo ""
echo "📝 Logs:"
echo "   - Succès: $LOG_FILE"
echo "   - Échecs: $FAILED_FILE"
echo ""
if [ -s "$FAILED_FILE" ]; then
    echo "⚠️  Certains téléchargements ont échoué. Consultez $FAILED_FILE"
    echo ""
fi

echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "  ✅ TÉLÉCHARGEMENT TERMINÉ !"
echo ""
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "🚀 PROCHAINES ÉTAPES:"
echo ""
echo "   1. Transférez le dossier 'docs' vers votre environnement air-gapped:"
echo "      tar czf devops-docs.tar.gz docs/"
echo ""
echo "   2. Uploadez dans Open WebUI:"
echo "      - Ouvrez http://localhost:3000"
echo "      - Allez dans 'Connaissances'"
echo "      - Créez une base par catégorie"
echo "      - Uploadez les fichiers"
echo ""
echo "   3. Organisation suggérée pour Open WebUI:"
echo "      - KB_Ansible (ansible/)"
echo "      - KB_Terraform (terraform/)"
echo "      - KB_Kubernetes (kubernetes/)"
echo "      - KB_Python (languages/python/)"
echo "      - KB_Security (security/)"
echo "      - KB_Monitoring (monitoring/)"
echo ""
echo "══════════════════════════════════════════════════════════════════"
