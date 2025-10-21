#!/bin/bash
# modules/labs/mutillidae/mutillidae.sh - Mutillidae Manager

# ==========================
# Configuration
# ==========================

CONTAINER_NAME="ghost-mutillidae"
DOCKER_IMAGE="webgoat/mutillidae2"
MUTILLIDAE_PORT=8083
PLATFORM="linux/arm64"

MODULE_DIR="${HOME}/ghost00ls/modules/labs/mutillidae"
LOG_DIR="${HOME}/ghost00ls/logs/labs"
LOG_FILE="${LOG_DIR}/mutillidae.log"

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

start_mutillidae() {
    clear
    banner
    echo -e "${CYAN}=== 🚀 Démarrage Mutillidae ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    start_container "$CONTAINER_NAME" "$DOCKER_IMAGE" "$MUTILLIDAE_PORT" 80 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        local ip=$(get_host_ip)
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ Mutillidae lancé !${NC}"
        echo -e "${CYAN}🔗 URL : http://${ip}:${MUTILLIDAE_PORT}/mutillidae${NC}"
        echo -e "${CYAN}📚 OWASP Top 10 + NOWASP${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
    
    read -p "👉 Entrée..."
}

stop_mutillidae() {
    clear
    banner
    echo -e "${CYAN}=== 🛑 Arrêt Mutillidae ===${NC}\n"
    
    stop_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

clean_mutillidae() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Nettoyage Mutillidae ===${NC}\n"
    
    clean_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

status_mutillidae() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Statut Mutillidae ===${NC}\n"
    
    status_container "$CONTAINER_NAME" "$MUTILLIDAE_PORT"
    
    echo
    read -p "👉 Entrée..."
}

show_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📜 Logs Mutillidae ===${NC}\n"
    
    show_container_logs "$CONTAINER_NAME" 50
    
    echo
    read -p "👉 Entrée..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations Mutillidae ===${NC}\n"
    
    local ip=$(get_host_ip)
    
    echo -e "${GREEN}🔗 URL  : http://${ip}:${MUTILLIDAE_PORT}/mutillidae${NC}"
    echo -e "${GREEN}🐳 Container : $CONTAINER_NAME${NC}"
    echo -e "${GREEN}📦 Image : $DOCKER_IMAGE${NC}"
    
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • SQL Injection"
    echo "   • XSS (Stored/Reflected)"
    echo "   • LFI/RFI"
    echo "   • Command Injection"
    echo "   • CSRF"
    echo "   • XXE"
    echo "   • Upload vulnerabilities"
    echo "   • Broken Authentication"
    
    echo
    read -p "👉 Entrée..."
}

install_mutillidae() {
    clear
    banner
    echo -e "${CYAN}=== 📥 Installation Mutillidae ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    pull_image "$DOCKER_IMAGE"
    
    echo
    read -p "👉 Entrée..."
}

# ==========================
# Menu
# ==========================

menu_mutillidae() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🐛 Mutillidae Manager ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer Mutillidae${NC}"
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
            1) start_mutillidae ;;
            2) install_mutillidae ;;
            3) status_mutillidae ;;
            4) show_info ;;
            5) show_logs ;;
            6) stop_mutillidae ;;
            7) clean_mutillidae ;;
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
    menu_mutillidae
fi
