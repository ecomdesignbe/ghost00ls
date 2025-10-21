#!/bin/bash
# modules/labs/bwapp/bwapp.sh - bWAPP Manager

# ==========================
# Configuration
# ==========================

CONTAINER_NAME="ghost-bwapp"
DOCKER_IMAGE="raesene/bwapp"
BWAPP_PORT=8084

MODULE_DIR="${HOME}/ghost00ls/modules/labs/bwapp"
LOG_DIR="${HOME}/ghost00ls/logs/labs"
LOG_FILE="${LOG_DIR}/bwapp.log"

# ==========================
# Sources
# ==========================

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/lib/docker_utils.sh

mkdir -p "$LOG_DIR" "$MODULE_DIR"

# ==========================
# Actions
# ==========================

start_bwapp() {
    clear
    banner
    echo -e "${CYAN}=== 🚀 Démarrage bWAPP ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    start_container "$CONTAINER_NAME" "$DOCKER_IMAGE" "$BWAPP_PORT" 80 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        local ip=$(get_host_ip)
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ bWAPP lancé !${NC}"
        echo -e "${CYAN}🔗 URL  : http://${ip}:${BWAPP_PORT}${NC}"
        echo -e "${CYAN}👤 User : bee${NC}"
        echo -e "${CYAN}🔑 Pass : bug${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
    
    read -p "👉 Entrée..."
}

stop_bwapp() {
    clear
    banner
    echo -e "${CYAN}=== 🛑 Arrêt bWAPP ===${NC}\n"
    
    stop_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

clean_bwapp() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Nettoyage bWAPP ===${NC}\n"
    
    clean_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

status_bwapp() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Statut bWAPP ===${NC}\n"
    
    status_container "$CONTAINER_NAME" "$BWAPP_PORT"
    
    echo
    read -p "👉 Entrée..."
}

show_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📜 Logs bWAPP ===${NC}\n"
    
    show_container_logs "$CONTAINER_NAME" 50
    
    echo
    read -p "👉 Entrée..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations bWAPP ===${NC}\n"
    
    local ip=$(get_host_ip)
    
    echo -e "${GREEN}🔗 URL  : http://${ip}:${BWAPP_PORT}${NC}"
    echo -e "${GREEN}👤 User : bee${NC}"
    echo -e "${GREEN}🔑 Pass : bug${NC}"
    echo -e "${GREEN}🐳 Container : $CONTAINER_NAME${NC}"
    
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • SQL Injection (GET/POST/Search)"
    echo "   • XSS (Reflected/Stored)"
    echo "   • CSRF"
    echo "   • Command Injection"
    echo "   • LFI/RFI"
    echo "   • XXE"
    echo "   • Broken Authentication"
    echo "   • File Upload"
    
    echo
    read -p "👉 Entrée..."
}

install_bwapp() {
    clear
    banner
    echo -e "${CYAN}=== 📥 Installation bWAPP ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    pull_image "$DOCKER_IMAGE"
    
    echo
    read -p "👉 Entrée..."
}

# ==========================
# Menu
# ==========================

menu_bwapp() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🐝 bWAPP Manager ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer bWAPP${NC}"
        echo -e "${GREEN}2) 📥 Installer / Pull image${NC}"
        echo -e "${GREEN}3) 📊 Statut${NC}"
        echo -e "${GREEN}4) 📋 Informations${NC}"
        echo -e "${YELLOW}5) 📜 Logs${NC}"
        echo -e "${RED}6) 🛑 Stopper${NC}"
        echo -e "${RED}7) 🧹 Nettoyer${NC}"
        echo -e "${MAGENTA}8) 💣 Exploits${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_bwapp ;;
            2) install_bwapp ;;
            3) status_bwapp ;;
            4) show_info ;;
            5) show_logs ;;
            6) stop_bwapp ;;
            7) clean_bwapp ;;
            8)
                if [ -f "${MODULE_DIR}/exploits.sh" ]; then
                    bash "${MODULE_DIR}/exploits.sh"
                else
                    echo -e "${RED}❌ exploits.sh manquant${NC}"
                    read -p "👉 Entrée..."
                fi
                ;;
            0) return ;;
            *)
                echo -e "${RED}❌ Invalide${NC}"
                sleep 1
                ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_bwapp
fi
