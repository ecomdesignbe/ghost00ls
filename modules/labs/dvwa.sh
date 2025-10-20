#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

MODULE_DIR=~/ghost00ls/modules/labs/dvwa
COMPOSE=~/ghost00ls/modules/labs/dvwa/compose.yml
CONTAINER_WEB=dvwa-web
CONTAINER_DB=dvwa-db
CONFIG_DIR=~/ghost00ls/modules/labs/dvwa/config
CONFIG_FILE="$CONFIG_DIR/config.inc.php"
DIST_FILE="$CONFIG_DIR/config.inc.php.dist"
LOG_DIR=~/ghost00ls/logs/labs
LOG_FILE="$LOG_DIR/dvwa.log"
DVWA_PORT=8081

mkdir -p "$LOG_DIR"

# ==========================
# Vérification et patch config
# ==========================
check_and_patch_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️ config.inc.php manquant → copie depuis .dist...${NC}"
        cp "$DIST_FILE" "$CONFIG_FILE"
    fi

    if ! grep -q "\$_DVWA\['SQLI_DB'\]" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout variable SQLI_DB...${NC}"
        echo "\$_DVWA['SQLI_DB'] = 'MySQL';" >> "$CONFIG_FILE"
    fi

    if ! grep -q "define('MYSQL'" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout define MYSQL...${NC}"
        echo "define('MYSQL', 'MySQL');" >> "$CONFIG_FILE"
    fi

    if ! grep -q "define('SQLITE'" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout define SQLITE...${NC}"
        echo "define('SQLITE', 'sqlite');" >> "$CONFIG_FILE"
    fi

    echo -e "${GREEN}✅ config.inc.php vérifié et patché.${NC}"
}

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

start_dvwa() {
    echo -e "${YELLOW}⏳ Démarrage DVWA...${NC}" | tee -a "$LOG_FILE"
    
    if ! check_docker; then
        read -p "👉 Entrée pour revenir..."
        return
    fi

    echo -e "${YELLOW}⏳ Vérification config.inc.php...${NC}"
    check_and_patch_config

    echo -e "${YELLOW}⏳ Lancement DVWA...${NC}"
    docker compose -f $COMPOSE up -d --build >> "$LOG_FILE" 2>&1

    echo -e "${YELLOW}⏳ Vérification des healthchecks...${NC}"
    for i in {1..10}; do
        STATUS_DB=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_DB 2>/dev/null || echo "starting")
        STATUS_WEB=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_WEB 2>/dev/null || echo "starting")

        if [[ "$STATUS_DB" == "healthy" && "$STATUS_WEB" == "healthy" ]]; then
            IP=$(hostname -I | awk '{print $1}')
            echo -e "${GREEN}✅ DVWA est en ligne : http://$IP:${DVWA_PORT}${NC}" | tee -a "$LOG_FILE"
            break
        else
            echo -e "${YELLOW}⚠️ DVWA pas encore prêt... (tentative $i/10)${NC}"
            sleep 5
        fi
    done

    if [[ "$STATUS_WEB" != "healthy" ]]; then
        echo -e "${RED}❌ DVWA ne s'est pas lancé correctement.${NC}" | tee -a "$LOG_FILE"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

reset_database() {
    echo -e "${YELLOW}⏳ Réinitialisation DB...${NC}" | tee -a "$LOG_FILE"
    
    if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_DB$"; then
        echo -e "${RED}❌ Container DB non actif${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    docker exec -i $CONTAINER_DB mariadb -u dvwa -pp@ssw0rd dvwa < ~/ghost00ls/modules/labs/dvwa/reset.sql >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Base DVWA réinitialisée !${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}❌ Échec réinitialisation DB${NC}" | tee -a "$LOG_FILE"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations DVWA ===${NC}"
    echo
    IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}🔗 URL : http://$IP:${DVWA_PORT}${NC}"
    echo -e "${GREEN}🔌 Port : ${DVWA_PORT}${NC}"
    echo -e "${GREEN}👤 Login : admin${NC}"
    echo -e "${GREEN}🔑 Password : password${NC}"
    echo -e "${GREEN}🐳 Container Web : ${CONTAINER_WEB}${NC}"
    echo -e "${GREEN}🐳 Container DB : ${CONTAINER_DB}${NC}"
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • Brute Force"
    echo "   • Command Injection"
    echo "   • CSRF"
    echo "   • File Inclusion (LFI/RFI)"
    echo "   • File Upload"
    echo "   • Insecure CAPTCHA"
    echo "   • SQL Injection"
    echo "   • SQL Injection (Blind)"
    echo "   • Weak Session IDs"
    echo "   • XSS (DOM/Reflected/Stored)"
    echo "   • CSP Bypass"
    echo "   • JavaScript"
    echo
    read -p "👉 Entrée pour revenir..."
}

status_dvwa() {
    clear
    banner
    echo -e "${CYAN}📊 Statut DVWA :${NC}"
    echo
    
    # Check containers
    local web_running=0
    local db_running=0
    
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_WEB$"; then
        web_running=1
        echo -e "${GREEN}🐳 Container Web : running${NC}"
    else
        echo -e "${YELLOW}🐳 Container Web : stopped${NC}"
    fi
    
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_DB$"; then
        db_running=1
        echo -e "${GREEN}🐳 Container DB  : running${NC}"
    else
        echo -e "${YELLOW}🐳 Container DB  : stopped${NC}"
    fi
    
    if [ $web_running -eq 1 ]; then
        local IP=$(hostname -I | awk '{print $1}')
        echo
        echo -e "${GREEN}🔗 URL : http://$IP:${DVWA_PORT}${NC}"
        echo -e "${GREEN}👤 Login : admin${NC}"
        echo -e "${GREEN}🔑 Password : password${NC}"
        
        # Healthcheck
        local health_web=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_WEB 2>/dev/null || echo "unknown")
        local health_db=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_DB 2>/dev/null || echo "unknown")
        
        echo
        if [ "$health_web" = "healthy" ]; then
            echo -e "${GREEN}💚 Health Web : healthy${NC}"
        else
            echo -e "${YELLOW}⚠️ Health Web : $health_web${NC}"
        fi
        
        if [ "$health_db" = "healthy" ]; then
            echo -e "${GREEN}💚 Health DB  : healthy${NC}"
        else
            echo -e "${YELLOW}⚠️ Health DB  : $health_db${NC}"
        fi
    else
        echo
        echo -e "${YELLOW}⚠️ DVWA n'est pas en cours d'exécution${NC}"
        echo -e "${CYAN}💡 Utilisez l'option 1 pour lancer DVWA${NC}"
    fi
    
    echo
    read -p "👉 Entrée pour revenir..."
}

show_logs() {
    echo -e "${YELLOW}📜 Logs DVWA (50 dernières lignes)${NC}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_WEB$"; then
        docker compose -f $COMPOSE logs --tail=50
    else
        tail -n 50 "$LOG_FILE" 2>/dev/null || echo -e "${YELLOW}(Pas de logs disponibles)${NC}"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

stop_dvwa() {
    echo -e "${RED}⏳ Arrêt DVWA...${NC}" | tee -a "$LOG_FILE"
    docker compose -f $COMPOSE down >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}✅ DVWA stoppé.${NC}" | tee -a "$LOG_FILE"
    sleep 1
}

clean_dvwa() {
    echo -e "${RED}⏳ Nettoyage complet DVWA...${NC}" | tee -a "$LOG_FILE"
    docker compose -f $COMPOSE down -v >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}✅ Containers + volumes supprimés.${NC}" | tee -a "$LOG_FILE"
    sleep 1
}

# ==========================
# Menu principal
# ==========================

menu_dvwa() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🎯 DVWA (Damn Vulnerable Web App) ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer DVWA${NC}"
        echo -e "${GREEN}2) 🔄 Réinitialiser la base de données${NC}"
        echo -e "${GREEN}3) 📋 Infos connexion${NC}"
        echo -e "${GREEN}4) 📊 Statut${NC}"
        echo -e "${YELLOW}5) 📂 Logs DVWA${NC}"
        echo -e "${RED}6) 🛑 Stopper DVWA${NC}"
        echo -e "${RED}7) 🧹 Nettoyer DVWA${NC}"
        echo -e "${CYAN}8) 💣 Exemples d'exploitation${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_dvwa ;;
            2) reset_database ;;
            3) show_info ;;
            4) status_dvwa ;;
            5) show_logs ;;
            6) stop_dvwa ;;
            7) clean_dvwa ;;
            8) 
                if [ -f "$MODULE_DIR/exploits.sh" ]; then
                    source "$MODULE_DIR/exploits.sh"
                    exploits_menu
                else
                    echo -e "${RED}❌ Fichier exploits.sh introuvable${NC}"
                    read -p "👉 Entrée pour revenir..."
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}❌ Option invalide${NC}" ; sleep 1 ;;
        esac
    done
}

# Lancement si exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_dvwa
fi
