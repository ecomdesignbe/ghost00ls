#!/bin/bash
# ghost00ls_critical_fixes.sh
# Script auto-correction des bugs critiques identifiés
# Usage: bash ghost00ls_critical_fixes.sh

set -e

# Couleurs
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

GHOST_ROOT="${HOME}/ghost00ls"
BACKUP_DIR="${HOME}/ghost00ls_backups"
TIMESTAMP=$(date +%F_%H-%M-%S)

# Banner
clear
cat << "EOF"
   _____ _               _   ___   ___  _     
  / ____| |             | | / _ \ / _ \| |    
 | |  __| |__   ___  ___| || | | | | | | |___ 
 | | |_ | '_ \ / _ \/ __| || | | | | | | / __|
 | |__| | | | | (_) \__ \ || |_| | |_| | \__ \
  \_____|_| |_|\___/|___| | \___/ \___/|_|___/
                        |_|                    
          CRITICAL FIXES AUTOMATION
EOF

echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}🔧 Ghost00ls - Correctifs Critiques Automatisés${NC}"
echo -e "${CYAN}=================================================${NC}"
echo

# === Vérifications préalables ===
echo -e "${YELLOW}[1/8] Vérifications préalables...${NC}"

if [[ ! -d "$GHOST_ROOT" ]]; then
    echo -e "${RED}❌ $GHOST_ROOT introuvable${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Ghost00ls détecté${NC}"

# === Backup automatique ===
echo
echo -e "${YELLOW}[2/8] Création backup de sécurité...${NC}"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/ghost00ls_${TIMESTAMP}.tar.gz" "$GHOST_ROOT" 2>/dev/null

echo -e "${GREEN}✅ Backup : $BACKUP_DIR/ghost00ls_${TIMESTAMP}.tar.gz${NC}"

# === FIX 1 : Permissions config.sh (CRITIQUE) ===
echo
echo -e "${YELLOW}[3/8] FIX #1 - Sécurisation config.sh...${NC}"

CONFIG_FILE="$GHOST_ROOT/lib/config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
    # Vérifier permissions actuelles
    CURRENT_PERMS=$(stat -c %a "$CONFIG_FILE" 2>/dev/null)
    
    if [[ "$CURRENT_PERMS" != "600" && "$CURRENT_PERMS" != "400" ]]; then
        echo -e "${RED}⚠️ Permissions actuelles : $CURRENT_PERMS (VULNÉRABLE)${NC}"
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}✅ Permissions fixées : 600${NC}"
    else
        echo -e "${GREEN}✅ Permissions déjà sécurisées ($CURRENT_PERMS)${NC}"
    fi
    
    # Vérifier propriétaire
    chown $(whoami):$(whoami) "$CONFIG_FILE"
    echo -e "${GREEN}✅ Propriétaire : $(whoami)${NC}"
else
    echo -e "${RED}❌ $CONFIG_FILE introuvable${NC}"
fi

# === FIX 2 : automation.sh ligne 85 (typo path) ===
echo
echo -e "${YELLOW}[4/8] FIX #2 - Correction automation.sh typo...${NC}"

AUTO_FILE="$GHOST_ROOT/modules/automation.sh"

if [[ -f "$AUTO_FILE" ]]; then
    # Rechercher le bug
    if grep -q "~/ghostmodules/automation.sh" "$AUTO_FILE"; then
        echo -e "${RED}⚠️ Bug détecté (typo path)${NC}"
        
        # Backup du fichier
        cp "$AUTO_FILE" "$AUTO_FILE.bak"
        
        # Corriger
        sed -i 's|~/ghostmodules/automation.sh|~/ghost00ls/logs/automation.log|g' "$AUTO_FILE"
        
        echo -e "${GREEN}✅ Typo corrigée${NC}"
        echo -e "${CYAN}   Backup : $AUTO_FILE.bak${NC}"
    else
        echo -e "${GREEN}✅ Aucun bug détecté (déjà corrigé ou version différente)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ $AUTO_FILE introuvable (skip)${NC}"
fi

# === FIX 3 : dvwa/exploits.sh HTML tronqué ===
echo
echo -e "${YELLOW}[5/8] FIX #3 - Correction DVWA HTML tronqué...${NC}"

DVWA_FILE="$GHOST_ROOT/modules/labs/dvwa/exploits.sh"

if [[ -f "$DVWA_FILE" ]]; then
    # Rechercher HTML incomplet
    if grep -q 'backgroun\s*"' "$DVWA_FILE"; then
        echo -e "${RED}⚠️ HTML tronqué détecté${NC}"
        
        # Backup
        cp "$DVWA_FILE" "$DVWA_FILE.bak"
        
        # Corriger (ligne ~950-960)
        sed -i 's|background:#111;color:#eee;padding:12px}|background:#111;color:#eee;padding:12px}table{border-collapse:collapse;width:100%}th,td{border:1px solid #222;padding:4px}th{background:#222}|' "$DVWA_FILE"
        
        echo -e "${GREEN}✅ HTML corrigé${NC}"
        echo -e "${CYAN}   Backup : $DVWA_FILE.bak${NC}"
    else
        echo -e "${GREEN}✅ HTML correct (déjà fixé)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ $DVWA_FILE introuvable (skip)${NC}"
fi

# === FIX 4 : install.sh division par zéro ===
echo
echo -e "${YELLOW}[6/8] FIX #4 - Sécurisation install.sh (division /0)...${NC}"

INSTALL_FILE="$GHOST_ROOT/modules/install.sh"

if [[ -f "$INSTALL_FILE" ]]; then
    # Rechercher calcul non protégé
    if grep -q 'percent=\$(( ok \* 100 / total ))' "$INSTALL_FILE"; then
        echo -e "${RED}⚠️ Calcul non sécurisé détecté${NC}"
        
        # Backup
        cp "$INSTALL_FILE" "$INSTALL_FILE.bak"
        
        # Corriger : ajouter protection
        sed -i '/local percent=\$(( ok \* 100 \/ total ))/c\
    local percent=0\
    if (( total > 0 )); then\
        percent=$(( ok * 100 / total ))\
    fi' "$INSTALL_FILE"
        
        echo -e "${GREEN}✅ Protection division par zéro ajoutée${NC}"
        echo -e "${CYAN}   Backup : $INSTALL_FILE.bak${NC}"
    else
        echo -e "${GREEN}✅ Calcul déjà protégé${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ $INSTALL_FILE introuvable (skip)${NC}"
fi

# === FIX 5 : Validation inputs utilisateur ===
echo
echo -e "${YELLOW}[7/8] FIX #5 - Ajout validation inputs globale...${NC}"

SANITIZE_LIB="$GHOST_ROOT/lib/sanitize.sh"

cat > "$SANITIZE_LIB" << 'EOFLIB'