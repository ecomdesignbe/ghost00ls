#!/bin/bash
# setup.sh - Installation initiale Ghost00ls
# Usage: curl -sSL https://raw.githubusercontent.com/ecomdesignbe/ghost00ls/main/setup.sh | bash

set -e

# Couleurs
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

# Banner
clear
cat << "EOF"
   ______  __  ______  _____ _______ ____   ____  _      _____ 
  / _____|/ / / / __ \/ ____|__   __/ __ \ / __ \| |    / ____|
 | |  __ / /_/ / |  | | (___   | | | |  | | |  | | |   | (___  
 | | |_ | ___  | |  | |\___ \  | | | |  | | |  | | |    \___ \ 
 | |__| | |  | | |__| |____) | | | | |__| | |__| | |___ ____) |
  \_____|_|  |_|\____/|_____/  |_|  \____/ \____/|_____|_____/ 
                                                                
            🔒 CyberSec Framework for Raspberry Pi 5
EOF

echo -e "${CYAN}=== Ghost00ls Installation ===${NC}"
echo

# === Vérifications préalables ===
echo -e "${YELLOW}[1/7] Vérifications système...${NC}"

# Architecture ARM64
if [[ "$(uname -m)" != "aarch64" ]]; then
    echo -e "${RED}⚠️ Warning: Ce framework est optimisé pour ARM64${NC}"
    read -p "Continuer quand même ? [y/N] : " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && exit 1
fi

# OS compatible
if ! grep -qiE 'parrot|kali|debian|ubuntu' /etc/os-release 2>/dev/null; then
    echo -e "${RED}⚠️ OS non testé. Compatible: ParrotOS, Kali, Debian, Ubuntu${NC}"
fi

# Sudo disponible
if ! command -v sudo &>/dev/null; then
    echo -e "${RED}❌ 'sudo' requis${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Vérifications OK${NC}"

# === Installation dépendances de base ===
echo
echo -e "${YELLOW}[2/7] Installation dépendances...${NC}"

sudo apt update -qq
sudo apt install -y git curl jq tree wget gnupg2 ca-certificates 2>&1 | grep -v "^Setting up"

echo -e "${GREEN}✅ Dépendances installées${NC}"

# === Clone du repo ===
echo
echo -e "${YELLOW}[3/7] Clone du repository...${NC}"

if [[ -d ~/ghost00ls ]]; then
    echo -e "${YELLOW}⚠️ ~/ghost00ls existe déjà${NC}"
    read -p "Sauvegarder et réinstaller ? [y/N] : " BACKUP
    if [[ "$BACKUP" =~ ^[yY]$ ]]; then
        mv ~/ghost00ls ~/ghost00ls.bak.$(date +%s)
        echo -e "${GREEN}✅ Backup créé${NC}"
    else
        echo -e "${RED}Installation annulée${NC}"
        exit 1
    fi
fi

git clone https://github.com/ecomdesignbe/ghost00ls.git ~/ghost00ls
cd ~/ghost00ls

echo -e "${GREEN}✅ Repository cloné${NC}"

# === Structure de dossiers ===
echo
echo -e "${YELLOW}[4/7] Création structure...${NC}"

mkdir -p ~/ghost00ls/{logs/{system,automated_scans,monitoring,threat_intel},reports,tmp,cron,wordlists}

# Permissions sécurisées
chmod 700 ~/ghost00ls/logs
chmod 700 ~/ghost00ls/tmp

echo -e "${GREEN}✅ Structure créée${NC}"

# === Permissions exécutables ===
echo
echo -e "${YELLOW}[5/7] Configuration permissions...${NC}"

chmod +x ghost-menu.sh
find modules -name "*.sh" -exec chmod +x {} \;
find lib -name "*.sh" -exec chmod +x {} \;

# Sécuriser config.sh
chmod 600 lib/config.sh

echo -e "${GREEN}✅ Permissions OK${NC}"

# === Configuration API Keys ===
echo
echo -e "${YELLOW}[6/7] Configuration API Keys...${NC}"
echo

echo -e "${CYAN}GhostGPT nécessite une clé Groq (gratuite)${NC}"
echo -e "Créer un compte sur: ${CYAN}https://console.groq.com${NC}"
echo
read -p "🔑 Clé Groq API (ou [Enter] pour skip) : " GROQ_KEY

if [[ -n "$GROQ_KEY" ]]; then
    sed -i "s|^export GROQ_API_KEY=.*|export GROQ_API_KEY=\"$GROQ_KEY\"|" lib/config.sh
    echo -e "${GREEN}✅ Clé Groq configurée${NC}"
else
    echo -e "${YELLOW}⚠️ Clé Groq non configurée - GhostGPT sera désactivé${NC}"
fi

echo
echo -e "${CYAN}Autres API optionnelles (appuie [Enter] pour skip) :${NC}"

read -p "🔑 VirusTotal API : " VT_KEY
[[ -n "$VT_KEY" ]] && echo "export VIRUSTOTAL_API_KEY=\"$VT_KEY\"" >> lib/config.sh

read -p "🔑 Shodan API : " SHODAN_KEY
[[ -n "$SHODAN_KEY" ]] && echo "export SHODAN_API_KEY=\"$SHODAN_KEY\"" >> lib/config.sh

# === Installation outils essentiels ===
echo
echo -e "${YELLOW}[7/7] Installation outils essentiels...${NC}"
echo -e "${CYAN}Cela peut prendre 10-20 minutes selon votre connexion${NC}"
echo

read -p "🚀 Installer les outils maintenant ? [Y/n] : " INSTALL_TOOLS
INSTALL_TOOLS=${INSTALL_TOOLS:-Y}

if [[ "$INSTALL_TOOLS" =~ ^[yY]$ ]]; then
    echo -e "${YELLOW}Installation en cours...${NC}"
    
    # Outils de base
    sudo apt install -y nmap curl wget git jq python3-pip \
        hydra sqlmap netcat-traditional nikto \
        2>&1 | tee ~/ghost00ls/logs/system/initial_install.log | \
        grep -E "Setting up|Processing|Unpacking" | \
        while read -r line; do
            echo -ne "${GREEN}.${NC}"
        done
    
    echo
    echo -e "${GREEN}✅ Installation terminée${NC}"
    echo -e "${CYAN}Log complet : ~/ghost00ls/logs/system/initial_install.log${NC}"
else
    echo -e "${YELLOW}⚠️ Installation reportée${NC}"
    echo -e "${CYAN}Lance ~/ghost00ls/modules/install.sh plus tard${NC}"
fi

# === Finalisation ===
echo
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Installation Ghost00ls terminée !     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo

echo -e "${CYAN}🚀 Lancer le framework :${NC}"
echo -e "   ${YELLOW}cd ~/ghost00ls && ./ghost-menu.sh${NC}"
echo

echo -e "${CYAN}📚 Prochaines étapes :${NC}"
echo -e "   1. Configure tes API keys (lib/config.sh)"
echo -e "   2. Installe les outils manquants (Menu 2)"
echo -e "   3. Lance un lab (DVWA/Juice Shop) pour tester"
echo

echo -e "${CYAN}📖 Documentation :${NC}"
echo -e "   ${YELLOW}https://github.com/ecomdesignbe/ghost00ls${NC}"
echo

echo -e "${CYAN}🔒 Sécurité :${NC}"
echo -e "   ${RED}N'utilise ce framework QUE sur des cibles autorisées !${NC}"
echo

# Proposer de lancer immédiatement
read -p "🚀 Lancer Ghost00ls maintenant ? [Y/n] : " LAUNCH_NOW
LAUNCH_NOW=${LAUNCH_NOW:-Y}

if [[ "$LAUNCH_NOW" =~ ^[yY]$ ]]; then
    cd ~/ghost00ls
    ./ghost-menu.sh
fi