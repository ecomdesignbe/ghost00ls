#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

MODULE_DIR=~/ghost00ls/modules/labs/mutillidae
LOG_DIR=~/ghost00ls/logs/labs
LOG_FILE="$LOG_DIR/mutillidae.log"
CONTAINER_NAME=mutillidae
DOCKER_IMAGE=citizenstig/nowasp
MUTILLIDAE_PORT=8083

mkdir -p "$LOG_DIR"

# ==========================
# Vérifications
# ==========================
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}❌ Docker n'est pas installé${NC}"
        return 1
    fi
    return 0
}

# ==========================
# Fonctions de gestion
# ==========================

start_mutillidae() {
    echo -e "${YELLOW}⏳ Démarrage Mutillidae...${NC}" | tee -a "$LOG_FILE"
    
    if ! check_docker; then
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    # Vérifier si déjà en cours
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${YELLOW}⚠️ Mutillidae est déjà en cours d'exécution${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    sudo docker run -d --rm --name "$CONTAINER_NAME" \
        -p "${MUTILLIDAE_PORT}:80" "$DOCKER_IMAGE" >>"$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "${GREEN}✅ Mutillidae lancé : http://$IP:${MUTILLIDAE_PORT}/mutillidae${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}❌ Échec du démarrage${NC}" | tee -a "$LOG_FILE"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

stop_mutillidae() {
    echo -e "${YELLOW}⏳ Arrêt Mutillidae...${NC}" | tee -a "$LOG_FILE"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        sudo docker stop "$CONTAINER_NAME" >>"$LOG_FILE" 2>&1
        echo -e "${GREEN}✅ Mutillidae stoppé${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ Aucun container Mutillidae trouvé${NC}" | tee -a "$LOG_FILE"
    fi
    
    sleep 1
}

clean_mutillidae() {
    echo -e "${YELLOW}⏳ Nettoyage Mutillidae...${NC}" | tee -a "$LOG_FILE"
    sudo docker rm -f "$CONTAINER_NAME" >>"$LOG_FILE" 2>&1
    echo -e "${GREEN}✅ Mutillidae nettoyé${NC}" | tee -a "$LOG_FILE"
    sleep 1
}

status_mutillidae() {
    echo -e "${CYAN}📊 Statut Mutillidae :${NC}"
    
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${GREEN}running (container: $CONTAINER_NAME)${NC}"
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "URL : http://$IP:${MUTILLIDAE_PORT}/mutillidae"
    else
        echo -e "${YELLOW}stopped${NC}"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

show_logs() {
    echo -e "${YELLOW}📜 Logs Mutillidae (50 dernières lignes)${NC}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        sudo docker logs --tail 50 "$CONTAINER_NAME"
    else
        tail -n 50 "$LOG_FILE" 2>/dev/null || echo -e "${YELLOW}(Pas de logs disponibles)${NC}"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations Mutillidae ===${NC}"
    echo
    local IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}🔗 URL : http://$IP:${MUTILLIDAE_PORT}/mutillidae${NC}"
    echo -e "${GREEN}🔌 Port : ${MUTILLIDAE_PORT}${NC}"
    echo -e "${GREEN}🐳 Container : ${CONTAINER_NAME}${NC}"
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • SQL Injection"
    echo "   • XSS (Stored/Reflected)"
    echo "   • LFI/RFI"
    echo "   • Command Injection"
    echo "   • CSRF"
    echo "   • XXE"
    echo "   • Upload vulnerabilities"
    echo
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Menu principal
# ==========================

menu_mutillidae() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🐛 Mutillidae (NOWASP) ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer Mutillidae${NC}"
        echo -e "${GREEN}2) 📊 Statut${NC}"
        echo -e "${GREEN}3) 📋 Infos connexion${NC}"
        echo -e "${YELLOW}4) 📂 Logs Mutillidae${NC}"
        echo -e "${RED}5) 🛑 Stopper Mutillidae${NC}"
        echo -e "${RED}6) 🧹 Nettoyer Mutillidae${NC}"
        echo -e "${CYAN}7) 💣 Exemples d'exploitation${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_mutillidae ;;
            2) status_mutillidae ;;
            3) show_info ;;
            4) show_logs ;;
            5) stop_mutillidae ;;
            6) clean_mutillidae ;;
            7) 
                if [ -f "$MODULE_DIR/exploits.sh" ]; then
                    source "$MODULE_DIR/exploits.sh"
                    menu_exploits
                else
                    echo -e "${RED}❌ Fichier exploits.sh introuvable${NC}"
                    read -p "👉 Entrée pour revenir..."
                fi
                ;;
            0) break ;;
            *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
        esac
    done
}

# Lancement si exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_mutillidae
fi
