#!/bin/bash
# modules/labs/juiceshop/juiceshop.sh - Juice Shop Manager

# ==========================
# Configuration
# ==========================

CONTAINER_NAME="ghost-juice"
DOCKER_IMAGE="bkimminich/juice-shop:latest"
JUICE_PORT=3000
PLATFORM="linux/arm64"

MODULE_DIR="${HOME}/ghost00ls/modules/labs/juiceshop"
LOG_DIR="${HOME}/ghost00ls/logs/labs"
LOG_FILE="${LOG_DIR}/juiceshop.log"

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

start_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🚀 Démarrage Juice Shop ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    start_container "$CONTAINER_NAME" "$DOCKER_IMAGE" "$JUICE_PORT" 3000 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        local ip=$(get_host_ip)
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ Juice Shop lancé !${NC}"
        echo -e "${CYAN}🔗 URL : http://${ip}:${JUICE_PORT}${NC}"
        echo -e "${CYAN}📚 OWASP Top 10 challenges${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
    
    read -p "👉 Entrée..."
}

stop_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🛑 Arrêt Juice Shop ===${NC}\n"
    
    stop_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

clean_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Nettoyage Juice Shop ===${NC}\n"
    
    clean_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    sleep 1
}

status_juice() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Statut Juice Shop ===${NC}\n"
    
    status_container "$CONTAINER_NAME" "$JUICE_PORT"
    
    echo
    read -p "👉 Entrée..."
}

show_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📜 Logs Juice Shop ===${NC}\n"
    
    show_container_logs "$CONTAINER_NAME" 50
    
    echo
    read -p "👉 Entrée..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations Juice Shop ===${NC}\n"
    
    local ip=$(get_host_ip)
    
    echo -e "${GREEN}🔗 URL  : http://${ip}:${JUICE_PORT}${NC}"
    echo -e "${GREEN}🐳 Container : $CONTAINER_NAME${NC}"
    echo -e "${GREEN}📦 Image : $DOCKER_IMAGE${NC}"
    
    echo
    echo -e "${CYAN}📚 OWASP Top 10 disponibles :${NC}"
    echo "   • Broken Access Control"
    echo "   • Cryptographic Failures"
    echo "   • Injection (SQL, XSS...)"
    echo "   • Insecure Design"
    echo "   • Security Misconfiguration"
    echo "   • Vulnerable Components"
    echo "   • Authentication Failures"
    
    echo
    read -p "👉 Entrée..."
}

install_juice() {
    clear
    banner
    echo -e "${CYAN}=== 📥 Installation Juice Shop ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    pull_image "$DOCKER_IMAGE"
    
    echo
    read -p "👉 Entrée..."
}

# ==========================
# Menu
# ==========================

menu_juice() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🥤 Juice Shop Manager ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer Juice Shop${NC}"
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
            1) start_juice ;;
            2) install_juice ;;
            3) status_juice ;;
            4) show_info ;;
            5) show_logs ;;
            6) stop_juice ;;
            7) clean_juice ;;
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
    menu_juice
fi
