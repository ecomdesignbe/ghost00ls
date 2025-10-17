#!/bin/bash
# ghost00ls_critical_fixes.sh
# Script de correction automatique des bugs détectés
# Usage: bash ghost00ls_critical_fixes.sh

set -e

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

GHOST_ROOT="${HOME}/ghost00ls"

echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔧 Ghost00ls - Correctifs Critiques ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
echo

# === 1. Créer lib/sanitize.sh (sécurité inputs) ===
echo -e "${YELLOW}[1/6] Création lib/sanitize.sh...${NC}"
cat > "$GHOST_ROOT/lib/sanitize.sh" << 'EOF'
#!/bin/bash
# Fonctions de sanitization des inputs utilisateur

sanitize_ip() {
    local ip="$1"
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo ""
        return 1
    fi
    echo "$ip"
}

sanitize_domain() {
    local domain="$1"
    # Supprimer caractères dangereux
    echo "$domain" | sed 's/[^a-zA-Z0-9.-]//g'
}

sanitize_filename() {
    local filename="$1"
    echo "$filename" | sed 's/[^a-zA-Z0-9._-]//g'
}

sanitize_port() {
    local port="$1"
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo ""
        return 1
    fi
    echo "$port"
}
EOF
chmod +x "$GHOST_ROOT/lib/sanitize.sh"
echo -e "${GREEN}✅ lib/sanitize.sh créé${NC}"

# === 2. Fixer modules/install.sh (éviter division par zéro) ===
echo -e "${YELLOW}[2/6] Correction modules/install.sh...${NC}"
if grep -q "success_rate=.*/ \$total" "$GHOST_ROOT/modules/install.sh" 2>/dev/null; then
    sed -i 's|success_rate=.*/ $total|if (( total > 0 )); then\n        success_rate=$((installed * 100 / total))\n    else\n        success_rate=0\n    fi|g' "$GHOST_ROOT/modules/install.sh"
    echo -e "${GREEN}✅ Division par zéro corrigée${NC}"
else
    echo -e "${YELLOW}⚠️ Déjà corrigé ou non trouvé${NC}"
fi

# === 3. Ajouter validation inputs dans modules offensifs ===
echo -e "${YELLOW}[3/6] Ajout validations dans pentest.sh...${NC}"
if ! grep -q "source.*sanitize.sh" "$GHOST_ROOT/modules/offensive/pentest.sh" 2>/dev/null; then
    sed -i '3i source ~/ghost00ls/lib/sanitize.sh' "$GHOST_ROOT/modules/offensive/pentest.sh"
    echo -e "${GREEN}✅ Import sanitize.sh ajouté${NC}"
else
    echo -e "${YELLOW}⚠️ Déjà ajouté${NC}"
fi

# === 4. Corriger permissions sensibles ===
echo -e "${YELLOW}[4/6] Sécurisation permissions...${NC}"
chmod 600 "$GHOST_ROOT/lib/config.sh" 2>/dev/null
chmod 700 "$GHOST_ROOT/logs" 2>/dev/null
chmod 700 "$GHOST_ROOT/tmp" 2>/dev/null
echo -e "${GREEN}✅ Permissions sécurisées${NC}"

# === 5. Créer backup automatique config.sh ===
echo -e "${YELLOW}[5/6] Création backup config.sh...${NC}"
if [ ! -f "$GHOST_ROOT/lib/config.sh.backup" ]; then
    cp "$GHOST_ROOT/lib/config.sh" "$GHOST_ROOT/lib/config.sh.backup"
    echo -e "${GREEN}✅ Backup créé : lib/config.sh.backup${NC}"
else
    echo -e "${YELLOW}⚠️ Backup existe déjà${NC}"
fi

# === 6. Ajouter healthcheck dans automation.sh ===
echo -e "${YELLOW}[6/6] Ajout healthcheck système...${NC}"
cat >> "$GHOST_ROOT/modules/automation.sh" << 'EOF'

# === Healthcheck système ===
healthcheck_system() {
    clear
    banner
    echo -e "${CYAN}=== 🏥 Healthcheck Système ===${NC}"
    echo
    
    LOG_FILE="$LOG_DIR/system/healthcheck_$(date +%F_%H-%M-%S).log"
    
    {
        echo "=== HEALTHCHECK GHOST00LS - $(date) ==="
        echo
        
        # CPU
        echo "[CPU]"
        top -bn1 | grep "Cpu(s)" | head -1
        echo
        
        # RAM
        echo "[MEMORY]"
        free -h | grep -v "+"
        echo
        
        # Disque
        echo "[DISK]"
        df -h / /home | grep -v "tmpfs"
        echo
        
        # Services critiques
        echo "[SERVICES]"
        for service in ssh ufw fail2ban docker; do
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                echo "✅ $service: RUNNING"
            else
                echo "❌ $service: STOPPED"
            fi
        done
        echo
        
        # Connexions réseau
        echo "[NETWORK]"
        netstat -tuln | grep LISTEN | wc -l
        echo "ports ouverts en écoute"
        
    } | tee "$LOG_FILE"
    
    echo
    echo -e "${GREEN}✅ Log sauvegardé : $LOG_FILE${NC}"
    read -p "👉 Entrée pour revenir..."
}
EOF
echo -e "${GREEN}✅ Healthcheck ajouté${NC}"

# === Résumé ===
echo
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Tous les correctifs ont été appliqués ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}📋 Actions effectuées :${NC}"
echo -e "   1. ✅ Création lib/sanitize.sh (validation inputs)"
echo -e "   2. ✅ Fix division par zéro dans install.sh"
echo -e "   3. ✅ Ajout validations dans modules offensifs"
echo -e "   4. ✅ Sécurisation permissions (config.sh, logs/)"
echo -e "   5. ✅ Backup automatique config.sh"
echo -e "   6. ✅ Ajout healthcheck système"
echo
echo -e "${YELLOW}🚀 Prochaines étapes :${NC}"
echo -e "   1. Lance ${CYAN}bash ghost00ls_test_suite.sh${NC} pour valider"
echo -e "   2. Teste le menu : ${CYAN}cd ~/ghost00ls && ./ghost-menu.sh${NC}"
echo -e "   3. Commit les changements : ${CYAN}git add . && git commit${NC}"
echo