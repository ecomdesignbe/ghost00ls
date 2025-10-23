#!/bin/bash
# modules/labs/juiceshop/juiceshop.sh - Juice Shop Manager v2.0 FIXED

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
# Fonctions utilitaires
# ==========================

get_host_ip() {
    hostname -I 2>/dev/null | awk '{print $1}'
}

# ==========================
# Fonctions Juice Shop
# ==========================

wait_juice_ready() {
    echo -e "${YELLOW}⏳ Attente démarrage Juice Shop (max 60s)...${NC}"
    
    local max_wait=12
    local count=0
    local ip=$(get_host_ip)
    
    while [ $count -lt $max_wait ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://${ip}:${JUICE_PORT}" | grep -q "200"; then
            echo -e "${GREEN}✅ Juice Shop prêt !${NC}"
            return 0
        fi
        
        count=$((count + 1))
        echo -e "${CYAN}⏳ Tentative $count/$max_wait...${NC}"
        sleep 5
    done
    
    echo -e "${YELLOW}⚠️ Juice Shop pas encore prêt (peut fonctionner quand même)${NC}"
    return 1
}

# ==========================
# Actions
# ==========================

start_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🚀 Démarrage Juice Shop ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${YELLOW}⚠️ Juice Shop déjà actif${NC}"
        read -p "👉 Entrée..."
        return 0
    fi
    
    echo -e "${YELLOW}⏳ Lancement du container...${NC}"
    
    docker run -d --rm --name "$CONTAINER_NAME" \
        --platform "$PLATFORM" \
        -p "${JUICE_PORT}:3000" \
        "$DOCKER_IMAGE" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        wait_juice_ready
        
        local ip=$(get_host_ip)
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ Juice Shop lancé !${NC}"
        echo -e "${CYAN}🔗 URL      : http://${ip}:${JUICE_PORT}${NC}"
        echo -e "${CYAN}📚 OWASP Top 10 challenges${NC}"
        echo -e "${CYAN}🎯 100+ vulnérabilités${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Juice Shop started" >> "$LOG_FILE"
    else
        echo -e "${RED}❌ Échec lancement${NC}"
    fi
    
    read -p "👉 Entrée..."
}

stop_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🛑 Arrêt Juice Shop ===${NC}\n"
    
    stop_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    
    echo -e "${GREEN}✅ Juice Shop stoppé${NC}"
    sleep 1
}

clean_juice() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Nettoyage Juice Shop ===${NC}\n"
    
    clean_container "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    
    echo -e "${GREEN}✅ Juice Shop nettoyé${NC}"
    sleep 1
}

status_juice() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Statut Juice Shop ===${NC}\n"
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}🐳 Container : running${NC}"
        
        local ip=$(get_host_ip)
        echo
        echo -e "${CYAN}🔗 URL : http://${ip}:${JUICE_PORT}${NC}"
        
        # Test de connectivité
        if curl -s -o /dev/null -w "%{http_code}" "http://${ip}:${JUICE_PORT}" | grep -q "200"; then
            echo -e "${GREEN}💚 Health : responding${NC}"
        else
            echo -e "${YELLOW}⚠️ Health : not responding yet${NC}"
        fi
        
        # Stats container
        echo
        echo -e "${CYAN}📊 Container stats:${NC}"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" "$CONTAINER_NAME"
    else
        echo -e "${YELLOW}🐳 Container : stopped${NC}"
    fi
    
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
    
    echo -e "${GREEN}🔗 URL       : http://${ip}:${JUICE_PORT}${NC}"
    echo -e "${GREEN}🐳 Container : $CONTAINER_NAME${NC}"
    echo -e "${GREEN}📦 Image     : $DOCKER_IMAGE${NC}"
    echo -e "${GREEN}📂 Path      : $MODULE_DIR${NC}"
    
    echo
    echo -e "${CYAN}📚 Catégories de vulnérabilités :${NC}"
    echo "   • 🔓 Broken Access Control"
    echo "   • 🔐 Cryptographic Failures"
    echo "   • 💉 Injection (SQL, XSS, NoSQL)"
    echo "   • 🎨 Insecure Design"
    echo "   • ⚙️  Security Misconfiguration"
    echo "   • 📦 Vulnerable Components"
    echo "   • 🔑 Authentication Failures"
    echo "   • 📊 Data Integrity Failures"
    echo "   • 🔍 Security Logging Failures"
    echo "   • 🚨 SSRF (Server-Side Request Forgery)"
    
    echo
    echo -e "${CYAN}🎯 Challenges disponibles :${NC}"
    echo "   • 100+ défis OWASP"
    echo "   • Scoreboard : http://${ip}:${JUICE_PORT}/#/score-board"
    echo "   • Niveaux : ⭐ à ⭐⭐⭐⭐⭐⭐"
    
    echo
    read -p "👉 Entrée..."
}

install_juice() {
    clear
    banner
    echo -e "${CYAN}=== 📥 Installation Juice Shop ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    
    echo -e "${YELLOW}⏳ Téléchargement de l'image Docker...${NC}"
    echo -e "${CYAN}Image : $DOCKER_IMAGE${NC}"
    echo -e "${CYAN}Plateforme : $PLATFORM${NC}"
    echo
    
    docker pull --platform "$PLATFORM" "$DOCKER_IMAGE"
    
    if [ $? -eq 0 ]; then
        echo
        echo -e "${GREEN}✅ Image installée avec succès${NC}"
        
        # Afficher taille
        local size=$(docker images "$DOCKER_IMAGE" --format "{{.Size}}")
        echo -e "${CYAN}📦 Taille : $size${NC}"
    else
        echo -e "${RED}❌ Échec téléchargement${NC}"
    fi
    
    echo
    read -p "👉 Entrée..."
}

open_browser() {
    clear
    banner
    echo -e "${CYAN}=== 🌐 Ouverture navigateur ===${NC}\n"
    
    local ip=$(get_host_ip)
    local url="http://${ip}:${JUICE_PORT}"
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${CYAN}URL : $url${NC}"
        echo -e "${YELLOW}⏳ Tentative ouverture...${NC}"
        
        # Essayer plusieurs commandes selon l'environnement
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$url" 2>/dev/null &
            echo -e "${GREEN}✅ Navigateur ouvert (xdg-open)${NC}"
        elif command -v firefox >/dev/null 2>&1; then
            firefox "$url" 2>/dev/null &
            echo -e "${GREEN}✅ Firefox ouvert${NC}"
        elif command -v chromium-browser >/dev/null 2>&1; then
            chromium-browser "$url" 2>/dev/null &
            echo -e "${GREEN}✅ Chromium ouvert${NC}"
        else
            echo -e "${YELLOW}⚠️  Aucun navigateur détecté${NC}"
            echo -e "${CYAN}💡 Ouvre manuellement : $url${NC}"
        fi
    else
        echo -e "${RED}❌ Juice Shop non actif${NC}"
        echo -e "${YELLOW}💡 Lance-le d'abord (option 1)${NC}"
    fi
    
    echo
    read -p "👉 Entrée..."
}

show_challenges() {
    clear
    banner
    echo -e "${CYAN}=== 🎯 Challenges OWASP ===${NC}\n"
    
    local ip=$(get_host_ip)
    
    echo -e "${GREEN}Scoreboard : http://${ip}:${JUICE_PORT}/#/score-board${NC}"
    echo
    echo -e "${CYAN}🌟 Quelques challenges populaires :${NC}"
    echo
    
    echo -e "${YELLOW}⭐ Facile :${NC}"
    echo "   • Trouver le scoreboard"
    echo "   • Injection SQL dans le login"
    echo "   • XSS DOM dans le search"
    echo "   • Accès admin sans login"
    
    echo -e "\n${YELLOW}⭐⭐ Moyen :${NC}"
    echo "   • Upload malveillant"
    echo "   • XXE (XML External Entity)"
    echo "   • CSRF token bypass"
    echo "   • JWT manipulation"
    
    echo -e "\n${YELLOW}⭐⭐⭐⭐ Difficile :${NC}"
    echo "   • RCE via Juggler"
    echo "   • NoSQL injection avancée"
    echo "   • Prototype pollution"
    echo "   • Race condition"
    
    echo -e "\n${YELLOW}⭐⭐⭐⭐⭐⭐ Expert :${NC}"
    echo "   • Supply chain attack"
    echo "   • Blockchain exploitation"
    echo "   • SSRF avec bypass"
    
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
        echo -e "${GREEN}1)  🚀 Lancer Juice Shop${NC}"
        echo -e "${GREEN}2)  📥 Installer / Pull image${NC}"
        echo -e "${GREEN}3)  📊 Statut${NC}"
        echo -e "${GREEN}4)  📋 Informations${NC}"
        echo -e "${GREEN}5)  🎯 Liste Challenges${NC}"
        echo -e "${GREEN}6)  🌐 Ouvrir navigateur${NC}"
        echo -e "${YELLOW}7)  📜 Logs${NC}"
        echo -e "${RED}8)  🛑 Stopper${NC}"
        echo -e "${RED}9)  🧹 Nettoyer${NC}"
        echo -e "${MAGENTA}10) 💣 Exploits${NC}"
        echo -e "${MAGENTA}11) 🎯 30+ Challenges OWASP${NC}"
        echo -e "${RED}0)  ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_juice ;;
            2) install_juice ;;
            3) status_juice ;;
            4) show_info ;;
            5) show_challenges ;;
            6) open_browser ;;
            7) show_logs ;;
            8) stop_juice ;;
            9) clean_juice ;;
            10)
                if [ -f "${MODULE_DIR}/exploits.sh" ]; then
                    bash "${MODULE_DIR}/exploits.sh"
                else
                    echo -e "${RED}❌ exploits.sh manquant${NC}"
                    read -p "👉 Entrée..."
                fi
                ;;
            11)
                if [ -f "${MODULE_DIR}/exploits_extended.sh" ]; then
                    bash "${MODULE_DIR}/exploits_extended.sh"
                else
                    echo -e "${RED}❌ exploits_extended.sh manquant${NC}"
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

# ==========================
# Lancement
# ==========================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_juice
fi
